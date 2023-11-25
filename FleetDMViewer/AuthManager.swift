//
//  AuthManager.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/24/23.
//

import Foundation
import KeychainWrapper

actor AuthManager {
    private var refreshTask: Task<Token, Error>?

    func validToken() async throws -> Token {
        if let handle = refreshTask {
            return try await handle.value
        }

        guard let token = KeychainWrapper.default.object(of: Token.self, forKey: "apiToken") else {
            throw AuthError.missingToken
        }

        if token.isValid {
            return token
        }

        return try await refreshToken()
    }

    func refreshToken() async throws -> Token {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }

        let task = Task { () throws -> Token in
            defer { refreshTask = nil }

            guard let email = KeychainWrapper.default.string(forKey: "email"),
                  let password = KeychainWrapper.default.string(forKey: "password") else {
                throw AuthError.missingCredentials
            }

            let credentials = LoginRequestBody(email: email, password: password)
            let response = try await NetworkManager(
                authManager: self
            ).fetch(
                .loginResponse, with: JSONEncoder().encode(credentials)
            )
            let newToken = Token(value: response.token, isValid: true)

            return newToken
        }

        self.refreshTask = task

        return try await task.value
    }

    enum AuthError: Error {
        case missingCredentials
        case missingToken
    }
}

struct Token: Codable {
    let value: String
    let isValid: Bool
}
