//
//  CachedSoftware.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import OSLog
import SwiftData

@Model
class CachedSoftware {
    var bundleIdentifier: String?
    var hostsCount: Int
    @Attribute(.unique) var id: Int
    var installedPaths: [String]?
    var lastOpenedAt: Date?
    var name: String
    var source: String
    var version: String
    var hosts = [CachedHost]()
    // swiftlint:disable:next line_length
    @Relationship(deleteRule: .cascade, inverse: \CachedVulnerability.software) var vulnerabilities = [CachedVulnerability]()

    init(
        bundleIdentifier: String? = nil,
        hostsCount: Int,
        id: Int,
        installedPaths: [String]? = nil,
        lastOpenedAt: Date? = nil,
        name: String,
        source: String,
        version: String
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.hostsCount = hostsCount
        self.id = id
        self.installedPaths = installedPaths
        self.lastOpenedAt = lastOpenedAt
        self.name = name
        self.source = source
        self.version = version
    }
}

extension CachedSoftware {
    convenience init(from software: Software) {
        self.init(
            bundleIdentifier: software.bundleIdentifier,
            hostsCount: software.hostsCount ?? 0,
            id: software.id,
            installedPaths: software.installedPaths,
            lastOpenedAt: software.lastOpenedAt,
            name: software.name,
            source: software.source,
            version: software.version
        )
    }
}

extension CachedSoftware {
    static func fetchSoftware() async throws -> [Software] {
        guard await DataController().activeEnvironment != nil else { throw HTTPError.invalidURL }

        do {
            return try await NetworkManager(authManager: AuthManager()).fetch(.software, attempts: 5)
        } catch {
            throw error
        }
    }

    static func fetchSoftware(forTeam id: Int) async throws -> [Software] {
        guard await DataController().activeEnvironment != nil else { throw HTTPError.invalidURL }
        let endpoint = Endpoint.getSoftwareForTeam(id: id)

        do {
            return try await NetworkManager(authManager: AuthManager()).fetch(endpoint, attempts: 5)
        } catch {
            throw error
        }
    }
}

extension CachedSoftware {
    fileprivate static let logger = Logger(subsystem: "com.daleribeiro.FleetDMViewer", category: "parsing")

    @MainActor
    static func refresh(forTeam id: Int? = nil, modelContext: ModelContext, dataController: DataController) async {
        do {
            dataController.loadingState = .loading
            var downloadedSoftware = [Software]()

            logger.debug("Refreshing the data store for software...")

            if let id = id {
                downloadedSoftware = try await fetchSoftware(forTeam: id)
            } else {
                downloadedSoftware = try await fetchSoftware()
            }

            logger.debug("Loaded: \(downloadedSoftware.count) software objects. ")

            for software in downloadedSoftware {
                let cachedSoftware = CachedSoftware(from: software)

                modelContext.insert(cachedSoftware)
                logger.debug("Inserted \(cachedSoftware.name)")

                if let vulnerabilities = software.vulnerabilities {
                    for vulnerability in vulnerabilities {
                        let cachedVulnerability = CachedVulnerability(from: vulnerability)

                        cachedSoftware.vulnerabilities.append(cachedVulnerability)

                    }
                }
            }

            try? modelContext.save()

            dataController.softwareLastUpdatedAt = .now
            dataController.loadingState = .loaded

            logger.debug("Refresh complete")
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error)
            case .none:
                print(error)
            }
        }
    }
}

extension CachedSoftware {
    static func predicate(
        searchText: String,
        isShowingVulnerableSoftware: Bool
    ) -> Predicate<CachedSoftware> {
        if isShowingVulnerableSoftware {
            return #Predicate<CachedSoftware> { software in
                (searchText.isEmpty || software.name.localizedStandardContains(searchText))
                && (!software.vulnerabilities.isEmpty)
            }
        } else {
            return #Predicate<CachedSoftware> { software in
                (searchText.isEmpty || software.name.localizedStandardContains(searchText))
            }
        }
    }
}

extension CachedSoftware: Identifiable {}
