//
//  DataController.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/21/23.
//

import Foundation
import KeychainWrapper
import SwiftData
import SwiftUI

// Enum to define loading state when network calls are made across the app.
enum LoadingState {
    case loading, loaded, failed
}

/* There's a lot in here and it should be cleaned up a bit.
 Everything that is shared across the app is here and much
 of it should proably be moved into a view model. There is
 still a bunch of code that controls dataflow for CoreData
 and that can probably stay. */
@MainActor
class DataController: ObservableObject {

    @Published var selectedFilter = Filter.all

    @Published var filterText = ""
    @Published var filterTokens = [SearchToken]()

    @Published var sortOldestFirst = true

    @Published var selectedTeam: CachedTeam?
    @Published var selectedHost: CachedHost?
    @Published var selectedUser: CachedUser?
    @Published var activeEnvironment: AppEnvironment?

    @Published var showingAlert = false
    @Published var showingApiTokenAlert = false
    @Published var apiTokenText = ""
    @Published var alertTitle = ""
    @Published var alertDescription = ""

    @Published var teamsLastUpdatedAt: Date? {
        didSet {
            UserDefaults.standard.setValue(teamsLastUpdatedAt, forKey: "teamsLastUpdatedAt")
        }
    }

    @Published var hostsLastUpdatedAt: Date? {
        didSet {
            UserDefaults.standard.setValue(hostsLastUpdatedAt, forKey: "hostsLastUpdatedAt")
        }
    }

    @Published var usersLastUpdatedAt: Date? {
        didSet {
            UserDefaults.standard.setValue(hostsLastUpdatedAt, forKey: "usersLastUpdatedAt")
        }
    }

    @Published var softwareLastUpdatedAt: Date? {
        didSet {
            UserDefaults.standard.setValue(softwareLastUpdatedAt, forKey: "softwareLastUpdatedAt")
        }
    }

    @Published var policiesLastUpdatedAt: Date? {
        didSet {
            UserDefaults.standard.setValue(policiesLastUpdatedAt, forKey: "policiesLastUpdatedAt")
        }
    }

    @Published var allTokens = [
        SearchToken(name: "macOS", platform: ["darwin"]),
        SearchToken(name: "Windows", platform: ["windows"]),
        SearchToken(name: "Linux", platform: ["rhel", "ubuntu"])
    ]

    @Published var loadingState = LoadingState.loaded

    private var saveTask: Task<Void, Error>?

    @Published var isAuthenticated: Bool = false {
        didSet {
            UserDefaults.standard.setValue(isAuthenticated, forKey: "isAuthenticated")
        }
    }

    init() {
        if let teamsLastUpdatedAt = UserDefaults.standard.value(forKey: "teamsLastUpdatedAt") as? Date {
            self.teamsLastUpdatedAt = teamsLastUpdatedAt
        }

        if let hostsLastUpdatedAt = UserDefaults.standard.value(forKey: "hostsLastUpdatedAt") as? Date {
            self.hostsLastUpdatedAt = hostsLastUpdatedAt
        }

        if let usersLastUpdatedAt = UserDefaults.standard.value(forKey: "usersLastUpdatedAt") as? Date {
            self.usersLastUpdatedAt = usersLastUpdatedAt
        }

        if let softwareLastUpdatedAt = UserDefaults.standard.value(forKey: "softwareLastUpdatedAt") as? Date {
            self.softwareLastUpdatedAt = softwareLastUpdatedAt
        }

        if let policiesLastUpdatedAt = UserDefaults.standard.value(forKey: "policiesLastUpdatedAt") as? Date {
            self.policiesLastUpdatedAt = policiesLastUpdatedAt
        }

        if let selectedFilter = UserDefaults.standard.value(forKey: "selectedFilter") as? Filter {
            self.selectedFilter = selectedFilter
        }

        if let isAuthenticated = UserDefaults.standard.value(forKey: "isAuthenticated") as? Bool {
            self.isAuthenticated = isAuthenticated
        }

        if let data = UserDefaults.standard.data(forKey: "activeEnvironment") {
            let decoded = try? JSONDecoder().decode(AppEnvironment.self, from: data)
            self.activeEnvironment = decoded
        }
    }

    private func saveActiveEnvironment(environment: AppEnvironment) {
        let encoded = try? JSONEncoder().encode(environment)
        UserDefaults.standard.set(encoded, forKey: "activeEnvironment")
    }

    /* Attempts to delete all persisent data by calling the delete
     method on the Swift Data modelContext. */
    func deleteAll(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: CachedTeam.self)
            try modelContext.delete(model: CachedHost.self)
            try modelContext.delete(model: CachedUser.self)
            try modelContext.delete(model: CachedSoftware.self)
            try modelContext.delete(model: CachedCommandResponse.self)
            try modelContext.delete(model: CachedPolicy.self)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func loginWithEmail(
        email: String,
        password: String,
        serverURL: String,
        networkManager: NetworkManager,
        modelContext: ModelContext
    ) async throws {

        KeychainWrapper.default.removeAllKeys()

        let environment = AppEnvironment(
            baseURL: URL(
                string: "\(try validateServerURL(serverURL))"
            )!
        )

        saveActiveEnvironment(environment: environment)

        let credentials = LoginRequestBody(email: email, password: password)

        do {
            let response = try await networkManager.fetch(
                .loginResponse,
                with: JSONEncoder().encode(credentials),
                allowRetry: false
            )

            let newToken = Token(value: response.token, isValid: true)
            KeychainWrapper.default.set(newToken, forKey: "apiToken")
            KeychainWrapper.default.set(email, forKey: "email")
            KeychainWrapper.default.set(password, forKey: "password")

            let user = response.user
            var teams: [Team] {
                if response.user.teams.isEmpty {
                    return response.availableTeams
                }

                return response.user.teams
            }

            deleteAll(modelContext: modelContext)

            await MainActor.run {
                updateCache(with: user, downloadedTeams: teams, modelContext: modelContext)
                activeEnvironment = environment
            }

            loadingState = .loaded
            AppEnvironments().addEnvironment(environment)
            isAuthenticated = true
        } catch let error as HTTPError {
            print(error.localizedDescription)
            handleLoginErrors(error: error)
        } catch {
            alertTitle = "Login Error"
            alertDescription = "\(error.localizedDescription)"
            showingAlert.toggle()
            print(error.localizedDescription)
            loadingState = .failed
        }
    }

    func loginWithApiKey(
        apiKey: String,
        serverURL: String,
        networkManager: NetworkManager,
        modelContext: ModelContext
    ) async throws {
        KeychainWrapper.default.removeAllKeys()

        let environment = AppEnvironment(
            baseURL: URL(
                string: "\(try validateServerURL(serverURL))"
            )!
        )
        saveActiveEnvironment(environment: environment)
        let newToken = Token(value: apiKey, isValid: true)

        do {
            KeychainWrapper.default.set(newToken, forKey: "apiToken")
            let response = try await networkManager.fetch(.meEndpoint)
            let user = response.user
            let teams = response.availableTeams

            deleteAll(modelContext: modelContext)

            await MainActor.run {
                updateCache(with: user, downloadedTeams: teams, modelContext: modelContext)
                activeEnvironment = environment
            }

            loadingState = .loaded
            AppEnvironments().addEnvironment(environment)
            isAuthenticated = true
        } catch let error as HTTPError {
            print(error.localizedDescription)
            handleLoginErrors(error: error)
        } catch {
            alertTitle = "Login Error"
            alertDescription = "\(error.localizedDescription)"
            showingAlert.toggle()
            print(error.localizedDescription)
            loadingState = .failed
        }
    }

    func handleLoginErrors(error: HTTPError) {
        switch error {
        case .statusCode(let statusCode):
            switch statusCode {
            case (401):
                alertTitle = "Authorization Error"
                alertDescription = "Your email address or password are incorrect."
                showingAlert.toggle()
                loadingState = .failed
            case (404):
                alertTitle = "Server Not Found"
                alertDescription = "Check your Fleet Server URL and try again."
                showingAlert.toggle()
                loadingState = .failed
            default:
                alertTitle = "Login Error"
                alertDescription = "Unown error. Please Try again"
                showingAlert.toggle()
                print(error.localizedDescription)
                loadingState = .failed
            }
        default:
            alertTitle = "Login Error"
            alertDescription = "\(error.localizedDescription)"
            showingAlert.toggle()
            print(error.localizedDescription)
            loadingState = .failed
        }
    }

    func signOut(modelContext: ModelContext) async {
        deleteAll(modelContext: modelContext)
        activeEnvironment = nil
        isAuthenticated = false
        teamsLastUpdatedAt = nil
        selectedHost = nil
        selectedTeam = nil

        do {
            _ = try await NetworkManager(authManager: AuthManager()).fetch(.logout)
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateCache(with downloadedUser: User, downloadedTeams: [Team], modelContext: ModelContext) {
        let cachedUser = CachedUser(
            apiOnly: downloadedUser.apiOnly,
            createdAt: downloadedUser.createdAt,
            email: downloadedUser.email,
            globalRole: downloadedUser.globalRole ?? "",
            gravatarUrl: downloadedUser.gravatarUrl,
            id: downloadedUser.id,
            name: downloadedUser.name,
            ssoEnabled: downloadedUser.ssoEnabled,
            updatedAt: downloadedUser.updatedAt
        )

        UserDefaults.standard.setValue(cachedUser.id, forKey: "loggedInUserID")

        for team in downloadedTeams {
            let cachedTeam = CachedTeam(id: team.id, name: team.name)
            modelContext.insert(cachedTeam)
            cachedUser.teams.append(cachedTeam)

        }

        modelContext.insert(cachedUser)

    }

    func validateServerURL(_ urlString: String) throws -> String {
        guard !urlString.isEmpty else {
            throw URLError(.badURL)
        }

        guard let url = URL(string: urlString), url.scheme != nil else {
            let validatedURLString = "https://" + urlString
            return validatedURLString

        }
        return urlString
    }
}
