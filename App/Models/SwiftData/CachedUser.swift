//
//  CachedUser.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import OSLog
import SwiftData

@Model
class CachedUser: Identifiable {
    var apiOnly: Bool
    var createdAt: Date
    var email: String
    var globalRole: String?
    var gravatarUrl: String
    @Attribute(.unique) var id: Int
    var lastFetched: Date?
    var name: String
    var ssoEnabled: Bool
    var updatedAt: Date
    @Relationship(inverse: \CachedTeam.users) var teams = [CachedTeam]()

    init(
        apiOnly: Bool,
        createdAt: Date,
        email: String,
        globalRole: String?,
        gravatarUrl: String,
        id: Int,
        lastFetched: Date? = nil,
        name: String,
        ssoEnabled: Bool,
        updatedAt: Date
    ) {
        self.apiOnly = apiOnly
        self.createdAt = createdAt
        self.email = email
        self.globalRole = globalRole
        self.gravatarUrl = gravatarUrl
        self.id = id
        self.lastFetched = lastFetched
        self.name = name
        self.ssoEnabled = ssoEnabled
        self.updatedAt = updatedAt
    }
}

extension CachedUser {
    convenience init(from user: User) {
        self.init(
            apiOnly: user.apiOnly,
            createdAt: user.createdAt,
            email: user.email,
            globalRole: user.globalRole,
            gravatarUrl: user.gravatarUrl,
            id: user.id,
            name: user.name,
            ssoEnabled: user.ssoEnabled,
            updatedAt: user.updatedAt
        )
    }
}

extension CachedUser {
    static func fetchUsers() async throws -> [User] {
        guard await DataController().activeEnvironment != nil else { throw HTTPError.invalidURL }

        do {
            return try await NetworkManager(authManager: AuthManager()).fetch(.users, attempts: 5)
        } catch {
            throw error
        }
    }
}

extension CachedUser {
    fileprivate static let logger = Logger(subsystem: "com.daleribeiro.FleetDMViewer", category: "parsing")

    @MainActor
    static func refresh(modelContext: ModelContext) async {
        do {
            logger.debug("Refreshing the data store for users...")
            let downloadedUsers = try await fetchUsers()
            logger.debug("Loaded: \(downloadedUsers.count) users")

            for user in downloadedUsers {
                let cachedUser = CachedUser(from: user)

                logger.debug("Inserting \(cachedUser.name)")
                modelContext.insert(cachedUser)

                logger.debug("Refresh complete.")
            }
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                let dataController = DataController()

                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error.localizedDescription)
            case .none:
                print(error.localizedDescription)
            }
        }
    }
}
