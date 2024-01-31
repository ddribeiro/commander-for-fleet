//
//  CachedTeam.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import OSLog
import SwiftData

@Model class CachedTeam {
    var hostCount: Int?
    @Attribute(.unique) var id: Int
    var name: String
    var role: String?
    @Relationship(deleteRule: .cascade, inverse: \CachedHost.team) var hosts = [CachedHost]()
    var users = [CachedUser]()

    init(
        hostCount: Int? = nil,
        id: Int,
        name: String,
        role: String? = nil
    ) {
        self.hostCount = hostCount
        self.id = id
        self.name = name
        self.role = role
    }
}

extension CachedTeam {
    convenience init(from team: Team) {
        self.init(
            hostCount: team.hostCount,
            id: team.id,
            name: team.name,
            role: team.role
        )
    }
}

extension CachedTeam {
    static func fetchTeams() async throws -> [Team] {
        guard await DataController().activeEnvironment != nil else { throw HTTPError.invalidURL }

        do {
            return try await NetworkManager(authManager: AuthManager()).fetch(.teams, attempts: 5)
        } catch {
            throw error
        }
    }
}

extension CachedTeam {
    fileprivate static let logger = Logger(subsystem: "com.daleribeiro.FleetDMViewer", category: "parsing")

    @MainActor
    static func refresh(modelContext: ModelContext) async {
        do {
            logger.debug("Refreshing the data store for teams...")
            let downloadedTeams = try await fetchTeams()
            logger.debug("Loaded \(downloadedTeams.count) teams")

            for team in downloadedTeams {
                let cachedTeam = CachedTeam(from: team)

                logger.debug(("Inserting \(cachedTeam.name)"))
                modelContext.insert(cachedTeam)
            }
            logger.debug("Refresh complete.")
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                var dataController = DataController()
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
