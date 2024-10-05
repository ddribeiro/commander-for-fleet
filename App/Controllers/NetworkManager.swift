//
//  NetworkManager.swift
//  fleet-dm-viewer
//
//  Created by Dale Ribeiro on 5/25/23.
//
import Foundation
import KeychainWrapper
import SwiftUI

struct AppEnvironment: Codable, Hashable {
    var name: String?
    var baseURL: URL
    var apiToken: String?

    enum CodingKeys: CodingKey {
        case name, baseURL
    }
}

class AppEnvironments: ObservableObject {
    @Published var environments: [AppEnvironment]

    let savePath = FileManager.documentsDirectory.appendingPathComponent("FleetDMViewer")

    init() {
        do {
            let data = try Data(contentsOf: savePath)
            self.environments = try JSONDecoder().decode([AppEnvironment].self, from: data)
        } catch {
            debugPrint(String(describing: error))
            self.environments = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(environments)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            debugPrint(String(describing: error))
        }
    }

    func addEnvironment(_ environment: AppEnvironment) {
        self.environments.append(environment)
        save()
    }
}

struct NetworkManager {
    var authManager = AuthManager()

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    var environment: AppEnvironment? {
        if let data = UserDefaults.standard.data(forKey: "activeEnvironment") {
            let decoded = try? JSONDecoder().decode(AppEnvironment.self, from: data)
            return decoded
        }
        return nil
    }

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, allowRetry: Bool = true) async throws -> T {
        guard let url = URL(string: resource.path, relativeTo: environment?.baseURL) else {
            throw URLError(.unsupportedURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = data
        request.allHTTPHeaderFields = resource.headers

        let configuration = URLSessionConfiguration.default
        if let apiToken = KeychainWrapper.default.object(of: Token.self, forKey: "apiToken") {
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(apiToken.value)"
            ]
        }

        do {
            var (responseData, response) = try await URLSession(configuration: configuration).data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    print(httpResponse.statusCode)
                    switch httpResponse.statusCode {
                    case 401:
                        if allowRetry {
                            let newToken = try await authManager.refreshToken()
                            KeychainWrapper.default.set(newToken, forKey: "apiToken")
                            return try await fetch(resource, with: data, allowRetry: false)
                        } else {
                            throw HTTPError.statusCode(httpResponse.statusCode)
                        }
                    default:
                        throw HTTPError.statusCode(httpResponse.statusCode)
                    }
                }
            }

            if let keyPath = resource.keyPath {
                if let rootObject = try JSONSerialization.jsonObject(with: responseData) as? NSDictionary {
                    if let nestedObject = rootObject.value(forKeyPath: keyPath) {

                        // swiftlint:disable:next line_length
                        responseData = try JSONSerialization.data(withJSONObject: nestedObject, options: [.fragmentsAllowed, .prettyPrinted])
                    }
                }
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601withOptionalFractionalSeconds
            return try decoder.decode(T.self, from: responseData)
        } catch {
            throw error
        }
    }

    // swiftlint:disable:next line_length
    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, attempts: Int, retryDelay: Double = 1) async throws -> T {
        do {
            print("Attempting to fetch (Attempts remaining: \(attempts))")
            return try await fetch(resource, with: data)
        } catch {
            if attempts > 1 {
                try await Task.sleep(for: .milliseconds(Int(retryDelay * 1000)))
                return try await fetch(resource, with: data, attempts: attempts - 1, retryDelay: retryDelay)
            } else {
                throw error
            }
        }
    }

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, defaultValue: T) async throws -> T {
        do {
            return try await fetch(resource, with: data)
        } catch {
            return defaultValue
        }
    }
}

enum HTTPError: Error {
    case statusCode(Int)
    case invalidURL
    case unexpectedResponse
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
