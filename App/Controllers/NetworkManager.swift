//
//  NetworkManager.swift
//  Commander
//
//  Created by Dale Ribeiro on 5/25/23.
//

import Foundation
import KeychainWrapper
import SwiftUI

struct AppEnvironment: Codable, Hashable, Identifiable {
    var id: String {
        baseURL.absoluteString
    }

    var name: String?
    var baseURL: URL
    var apiToken: String?

    enum CodingKeys: String, CodingKey {
        case name, baseURL, apiToken
    }

    init(name: String? = nil, baseURL: URL, apiToken: String? = nil) {
        self.name = name
        self.baseURL = baseURL
        self.apiToken = apiToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        baseURL = try container.decode(URL.self, forKey: .baseURL)
        apiToken = try container.decodeIfPresent(String.self, forKey: .apiToken)
    }
}

actor NetworkManager {
    private let authManager: AuthManager
    private let session: URLSession
    private let activeEnvironmentKey = "activeEnvironment"

    init(authManager: AuthManager) {
        self.authManager = authManager

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }

    /* The currently active environment. AuthService is the sole writer of
     the persisted copy, setting it during login and removing it on sign-out. */
    var environment: AppEnvironment? {
        guard let data = UserDefaults.standard.data(forKey: activeEnvironmentKey) else {
            return nil
        }
        return try? JSONDecoder().decode(AppEnvironment.self, from: data)
    }

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, allowRetry: Bool = true) async throws -> T where T: Decodable {
        try await fetch(resource, with: data, allowRetry: allowRetry, retryCount: 0)
    }

    private func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, allowRetry: Bool, retryCount: Int) async throws -> T where T: Decodable {
        guard let url = URL(string: resource.path, relativeTo: environment?.baseURL) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = data

        debugPrint("Network: \(request.httpMethod ?? "GET") \(url.absoluteString)")

        // Merge resource headers with auth headers
        var headers = resource.headers
        if resource.requiresAuth {
            let apiToken = try await authManager.validToken()
            headers["Authorization"] = "Bearer \(apiToken.value)"
        }
        request.allHTTPHeaderFields = headers

        do {
            let (responseData, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.unexpectedResponse
            }

            debugPrint("Network: \(httpResponse.statusCode) \(responseData.count) bytes")

            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    if allowRetry && retryCount < 2 && resource.requiresAuth {
                        debugPrint("Token expired, refreshing and retrying...")
                        let newToken = try await authManager.refreshToken()
                        KeychainWrapper.default.set(newToken, forKey: "apiToken")
                        return try await fetch(resource, with: data, allowRetry: allowRetry, retryCount: retryCount + 1)
                    } else {
                        throw HTTPError.statusCode(httpResponse.statusCode)
                    }
                default:
                    throw HTTPError.statusCode(httpResponse.statusCode)
                }
            }

            var processedData = responseData

            if let keyPath = resource.keyPath {
                if let rootObject = try JSONSerialization.jsonObject(with: processedData) as? NSDictionary {
                    if let nestedObject = rootObject.value(forKeyPath: keyPath) {
                        processedData = try JSONSerialization.data(withJSONObject: nestedObject)
                    }
                }
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Fleet date fields carry fractional seconds (e.g. seen_time).
            decoder.dateDecodingStrategy = .iso8601withOptionalFractionalSeconds

            do {
                return try decoder.decode(T.self, from: processedData)
            } catch {
                let body = String(data: processedData, encoding: .utf8) ?? "<not valid UTF-8, \(processedData.count) bytes>"
                debugPrint("Network: failed to decode \(T.self) (keyPath: \(resource.keyPath ?? "none"), body: \(resource.path)):\n\(String(body.prefix(2000)))")
                throw error
            }
        } catch {
            throw error
        }
    }

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, attempts: Int, retryDelay: Double = 1.0) async throws -> T where T: Decodable {
        var lastError: Error?

        for attempt in (1...attempts).reversed() {
            do {
                debugPrint("Attempting to fetch (Attempts remaining: \(attempt))")
                return try await fetch(resource, with: data)
            } catch {
                lastError = error

                if attempt > 1 {
                    let delay = retryDelay * Double(attempts - attempt + 1)
                    debugPrint("Request failed, retrying in \(delay)s...")
                    try await Task.sleep(for: .seconds(delay))
                }
            }
        }

        throw lastError!
    }

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, defaultValue: T) async throws -> T where T: Decodable {
        do {
            return try await fetch(resource, with: data)
        } catch {
            debugPrint("Using default value due to error: \(error.localizedDescription)")
            return defaultValue
        }
    }
}

enum HTTPError: LocalizedError {
    case statusCode(Int)
    case invalidURL
    case unexpectedResponse

    var errorDescription: String? {
        switch self {
        case .statusCode(let code):
            return "HTTP error with status code: \(code)"
        case .invalidURL:
            return "Invalid URL"
        case .unexpectedResponse:
            return "Unexpected response from server"
        }
    }
}

struct NetworkManagerKey: EnvironmentKey {
    static var defaultValue = NetworkManager(authManager: AuthManager())
}

extension EnvironmentValues {
    var networkManager: NetworkManager {
        get { self[NetworkManagerKey.self] }
        set { self[NetworkManagerKey.self] = newValue }
    }
}
