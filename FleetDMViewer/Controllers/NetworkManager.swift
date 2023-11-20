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
    var environment: AppEnvironment? {
        if let data = UserDefaults.standard.data(forKey: "activeEnvironment") {
            let decoded = try? JSONDecoder().decode(AppEnvironment.self, from: data)
            return decoded
        }
        return nil
    }

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil) async throws -> T {
        guard let url = URL(string: resource.path, relativeTo: environment?.baseURL) else {
            throw URLError(.unsupportedURL)
        }

        //        print(url.absoluteString)

        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = data
        request.allHTTPHeaderFields = resource.headers

        let configuration = URLSessionConfiguration.default
        if let apiToken = KeychainWrapper.default.string(forKey: "apiToken") {
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(apiToken)"
            ]
        }

        var (data, response) = try await URLSession(configuration: configuration).data(for: request)

        if let response = response as? HTTPURLResponse {
            if !(200...299).contains(response.statusCode) {
                print("Error code: \(response.statusCode)")
                throw HTTPError.statusCode(response.statusCode)
            }
        }

        if let keyPath = resource.keyPath {
            if let rootObject = try JSONSerialization.jsonObject(with: data) as? NSDictionary {
                if let nestedObject = rootObject.value(forKeyPath: keyPath) {

                    // swiftlint:disable:next line_length
                    data = try JSONSerialization.data(withJSONObject: nestedObject, options: [.fragmentsAllowed, .prettyPrinted])
                }
            }
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print(responseString)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    // swiftlint:disable:next line_length
    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, attempts: Int, retryDelay: Double = 1) async throws -> T {
        do {
            print("Attempting to fetch (Attempts remaining: \(attempts))")
            return try await fetch(resource, with: data)
        } catch let error as HTTPError {
            throw error
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
    static var defaultValue = NetworkManager()
}

extension EnvironmentValues {
    var networkManager: NetworkManager {
        get { self[NetworkManagerKey.self] }
        set { self[NetworkManagerKey.self] = newValue }
    }
}
