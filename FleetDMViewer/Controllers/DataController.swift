//
//  DataController.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/21/23.
//

import CoreData
import Foundation
import SwiftUI
import KeychainWrapper

enum SortType: String {
    case com
}

enum LoadingState {
case loading, loaded, failed
}

@MainActor
class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "FleetDMViewer")

    @Published var selectedFilter: Filter? = .all

    @Published var filterText = ""
    @Published var filterTokens = [Token]()

    @Published var selectedTeam: CachedTeam?
    @Published var selectedHost: CachedHost?
    @Published var activeEnvironment: AppEnvironment?

    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertDescription = ""

    @Published var teamsLastUpdatedAt: Date?
    @Published var hostsLastUpdatedAt: Date?

    @Published var allTokens = [
        Token(name: "macOS", platform: ["darwin"]),
        Token(name: "Windows", platform: ["windows"]),
        Token(name: "Linux", platform: ["rhel", "ubuntu"])
    ]

    @Published var loadingState = LoadingState.loaded

    private var saveTask: Task<Void, Error>?

    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false

    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }

            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
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

    func save() {
        saveTask?.cancel()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = CachedTeam.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = CachedUser.fetchRequest()
        delete(request2)

        let request3: NSFetchRequest<NSFetchRequestResult> = CachedUserTeam.fetchRequest()
        delete(request3)

        let request4: NSFetchRequest<NSFetchRequestResult> = CachedHost.fetchRequest()
        delete(request4)

    }

    func hostsForSelectedFilter() -> [CachedHost] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        if let team = filter.team {
            let teamPredicate = NSPredicate(format: "teamId CONTAINS %@", "\(team.id)")
            predicates.append(teamPredicate)
        } else {
            let datePredicate = NSPredicate(format: "lastEnrolledAt > %@", filter.minEnrollmentDate as NSDate)
            predicates.append(datePredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let hostNamePredicate = NSPredicate(format: "computerName CONTAINS[c] %@", trimmedFilterText)
            let serialNumberPredicate = NSPredicate(format: "hardwareSerial CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [hostNamePredicate, serialNumberPredicate]
            )

            predicates.append(combinedPredicate)
        }

        if filterTokens.isEmpty == false {
            var platformPredicates = [NSPredicate]()
            for filterToken in filterTokens {
                for platform in filterToken.platform {
                    let tokenPredicate = NSPredicate(format: "platform CONTAINS[c] %@", platform)
                    platformPredicates.append(tokenPredicate)
                }
            }
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: platformPredicates)
            predicates.append(combinedPredicate)
        }

        let request = CachedHost.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let allHosts = (try? container.viewContext.fetch(request)) ?? []
        return allHosts
    }

    func login(email: String, password: String, serverURL: String, networkManager: NetworkManager) async throws {
        let environment = AppEnvironment(
            baseURL: URL(
                string: "\(try validateServerURL(serverURL))"
            )!
        )

        saveActiveEnvironment(environment: environment)

        let credentials = LoginRequestBody(email: email, password: password)

        do {
            let response = try await networkManager.fetch(.loginResponse, with: JSONEncoder().encode(credentials))
            KeychainWrapper.default.set(response.token, forKey: "apiToken")
            let user = response.user
            let teams = response.availableTeams

            deleteAll()

            await MainActor.run {
                updateCache(with: user, downloadedTeams: teams)
                activeEnvironment = environment
            }
            loadingState = .loaded
            AppEnvironments().addEnvironment(environment)
            isAuthenticated = true
        } catch let error as HTTPError {
            loadingState = .failed
            switch error {
            case .statusCode(let statusCode):
                print("HTTP Status Code: \(statusCode)")
                showingAlert.toggle()
            case .invalidURL:

                alertTitle = "Invalid Server URL"
                alertDescription = "Check your server URL to make sure it is spelled correctly."
                showingAlert.toggle()
            case .unexpectedResponse:
                print("Unexpected response type")
            }
        }
    }

    func signOut() async {
        deleteAll()
        activeEnvironment = nil
        isAuthenticated = false
        teamsLastUpdatedAt = nil
        selectedHost = nil
        selectedTeam = nil

        do {
            _ = try await NetworkManager().fetch(.logout)
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateCache(with downloadedUser: User, downloadedTeams: [Team]) {
        let viewContext = container.viewContext
        let cachedUser = CachedUser(context: viewContext)

        cachedUser.createdAt = downloadedUser.createdAt
        cachedUser.updatedAt = downloadedUser.updatedAt
        cachedUser.id = Int16(downloadedUser.id)
        cachedUser.name = downloadedUser.name
        cachedUser.email = downloadedUser.email
        cachedUser.globalRole = downloadedUser.globalRole
        cachedUser.gravatarUrl = downloadedUser.gravatarUrl
        cachedUser.ssoEnabled = downloadedUser.ssoEnabled
        cachedUser.apiOnly = downloadedUser.apiOnly

        for team in downloadedTeams {
            let cachedTeam = CachedUserTeam(context: viewContext)
            cachedTeam.id = Int16(team.id)
            cachedTeam.name = team.name
            cachedTeam.teamDescription = team.description

            cachedUser.addToUserTeams(cachedTeam)
        }

        try? viewContext.save()
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
