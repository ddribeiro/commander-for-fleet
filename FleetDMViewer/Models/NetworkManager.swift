//
//  Authentication.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 5/25/23.
//

import SwiftUI
import Foundation
import KeychainWrapper

struct AppEnvironment {
    var name: String?
    var baseURL: URL
    var session: URLSession
}

struct NetworkManager {
    var environment: AppEnvironment

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil) async throws -> T {

        guard let url = URL(string: resource.path, relativeTo: environment.baseURL) else {
            throw URLError(.unsupportedURL)
        }

        print(url.absoluteString)

        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = data
        request.allHTTPHeaderFields = resource.headers

        var (data, _) = try await environment.session.data(for: request)

        if let keyPath = resource.keyPath {
            if let rootObject = try JSONSerialization.jsonObject(with: data) as? NSDictionary {
                if let nestedObject = rootObject.value(forKeyPath: keyPath) {
                    data = try JSONSerialization.data(withJSONObject: nestedObject, options: .fragmentsAllowed)
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

    func fetch<T>(_ resource: Endpoint<T>, with data: Data? = nil, attempts: Int, retryDelay: Double = 1) async throws -> T {
        do {
            print("Attempting to fetch (Attempts remaining: \(attempts)")
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
