//
//  AuthService.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/24/23.
//

import Foundation
import KeychainWrapper
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var loadingState: LoadingState = .loaded
    @Published var error: (title: String, description: String)?

    private let authManager: AuthManager
    private let networkManager: NetworkManager
    private let dataController: DataController

    init(authManager: AuthManager, networkManager: NetworkManager, dataController: DataController) {
        self.authManager = authManager
        self.networkManager = networkManager
        self.dataController = dataController

        // A token in the keychain means the last session was signed in.
        self.isAuthenticated = KeychainWrapper.default.object(of: Token.self, forKey: "apiToken") != nil
    }

    func login(email: String, password: String, serverURL: String) async throws {
        loadingState = .loading
        KeychainWrapper.default.removeAllKeys()

        let baseURLString = try dataController.validateServerURL(serverURL)
        guard let baseURL = URL(string: baseURLString) else {
            throw URLError(.badURL)
        }

        let environment = AppEnvironment(baseURL: baseURL)
        if let encoded = try? JSONEncoder().encode(environment) {
            UserDefaults.standard.set(encoded, forKey: "activeEnvironment")
        }
        dataController.activeEnvironment = environment

        let credentials = LoginRequestBody(email: email, password: password)

        do {
            let response = try await networkManager.fetch(
                .loginResponse,
                with: JSONEncoder().encode(credentials),
                allowRetry: false
            )

            let token = Token(value: response.token ?? "", isValid: true)
            KeychainWrapper.default.set(token, forKey: "apiToken")
            KeychainWrapper.default.set(email, forKey: "email")
            KeychainWrapper.default.set(password, forKey: "password")

            let userTeams = response.user?.teams ?? []
            let teams = userTeams.isEmpty ? (response.availableTeams ?? []) : userTeams
            dataController.syncLoginData(user: response.user, teams: teams)

            self.isAuthenticated = true
            self.loadingState = .loaded
        } catch {
            handleError(error)
            throw error
        }
    }

    func login(apiKey: String, serverURL: String) async throws {
        loadingState = .loading
        KeychainWrapper.default.removeAllKeys()

        let baseURLString = try dataController.validateServerURL(serverURL)
        guard let baseURL = URL(string: baseURLString) else {
            throw URLError(.badURL)
        }

        let environment = AppEnvironment(baseURL: baseURL)
        if let encoded = try? JSONEncoder().encode(environment) {
            UserDefaults.standard.set(encoded, forKey: "activeEnvironment")
        }
        dataController.activeEnvironment = environment

        let token = Token(value: apiKey, isValid: true)
        KeychainWrapper.default.set(token, forKey: "apiToken")

        do {
            let response = try await networkManager.fetch(.meEndpoint)
            dataController.syncLoginData(user: response.user, teams: response.availableTeams ?? [])

            self.isAuthenticated = true
            self.loadingState = .loaded
        } catch {
            handleError(error)
            throw error
        }
    }

    func signOut() async {
        // Best effort; the local sign-out proceeds regardless.
        try? await networkManager.fetch(.logout)

        KeychainWrapper.default.removeObject(forKey: "apiToken")
        KeychainWrapper.default.removeObject(forKey: "email")
        KeychainWrapper.default.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "activeEnvironment")

        dataController.reset()
        dataController.activeEnvironment = nil

        self.isAuthenticated = false
    }

    private func handleError(_ error: Error) {
        loadingState = .failed
        if let httpError = error as? HTTPError {
            switch httpError {
            case .statusCode(let code):
                if code == 401 {
                    self.error = ("Authorization Error", "Your email or password was incorrect.")
                } else if code == 404 {
                    self.error = ("Server Not Found", "Check the URL and try again.")
                } else {
                    self.error = ("Login Error", "Unexpected server response (\(code)).")
                }
            default:
                self.error = ("Login Error", error.localizedDescription)
            }
        } else {
            self.error = ("Login Error", error.localizedDescription)
        }
    }
}
