//
//  DataController.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/21/23.
//

import CoreData
import Foundation
import KeychainWrapper
import SwiftUI

/* There's a lot in here and it should be cleaned up a bit.
 Everything that is shared across the app is here and much
 of it should proably be moved into a view model. There is
 still a bunch of code that controls dataflow for CoreData
 and that can probably stay. */
@MainActor
// swiftlint:disable:next type_body_length
class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "FleetDMViewer")
    @Published var selectedFilter = Filter.all

    @Published var filterText = ""
    @Published var filterTokens = [SearchToken]()

    @Published var filterStatus = Status.all
    @Published var sortOldestFirst = true
    @Published var sortType = SortType.name

    @Published var selectedTeam: CachedTeam?
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

    /* Created a fetch request for each Core Data entity and deletes it. 
     This function needs to be updated as more functionality is added to
     the app and more data types are being saved.*/
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = CachedTeam.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = CachedUser.fetchRequest()
        delete(request2)

        let request3: NSFetchRequest<NSFetchRequestResult> = CachedSoftware.fetchRequest()
        delete(request3)
    }

//    func policiesforSelectedFilter() -> [Policy] {
//        let filter = selectedFilter
//        var predicates = [NSPredicate]()
//
//        if let team = filter.team {
//            let teamPredicate = NSPredicate(format: "teamId == %@", "\(team.id)")
//            predicates.append(teamPredicate)
//        }
//
//        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
//
//        if trimmedFilterText.isEmpty == false {
//            let userNamePredicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
//            let emailPredicate = NSPredicate(format: "authorName CONTAINS[c] %@", trimmedFilterText)
//            let combinedPredicate = NSCompoundPredicate(
//                orPredicateWithSubpredicates: [userNamePredicate, emailPredicate]
//            )
//
//            predicates.append(combinedPredicate)
//        }
//
//        let request = CachedPolicy.fetchRequest()
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        let allPolicies = (try? container.viewContext.fetch(request)) ?? []
//        return allPolicies
//    }

    func usersForSelectedFilter() -> [CachedUser] {
        let filter = selectedFilter
        var predicates = [NSPredicate]()

        if let team = filter.team {
            let teamPredicate = NSPredicate(format: "ANY teams.id = %@ OR teams.@count == 0", "\(team.id)")
            predicates.append(teamPredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let userNamePredicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
            let emailPredicate = NSPredicate(format: "email CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [userNamePredicate, emailPredicate]
            )

            predicates.append(combinedPredicate)
        }

        let request = CachedUser.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let allUsers = (try? container.viewContext.fetch(request)) ?? []
        return allUsers.sorted(by: { $0.wrappedName < $1.wrappedName })
    }

    func softwareForSelectedFilter() -> [CachedSoftware] {
        var predicates = [NSPredicate]()

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let softwareNamePredicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [softwareNamePredicate]
            )

            predicates.append(combinedPredicate)
        }
        let request = CachedSoftware.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let allSoftware = (try? container.viewContext.fetch(request)) ?? []
        return allSoftware
    }

    // swiftlint:disable:next function_body_length
//    func hostsForSelectedFilter() -> [Host] {
//        let filter = selectedFilter
//        var predicates = [NSPredicate]()
//        var sortDescriptors = [NSSortDescriptor]()
//
//        if let team = filter.team {
//            let teamPredicate = NSPredicate(format: "teamId CONTAINS %@", "\(team.id)")
//            predicates.append(teamPredicate)
//        } else {
//            let datePredicate = NSPredicate(format: "lastEnrolledAt > %@", filter.minEnrollmentDate as NSDate)
//            predicates.append(datePredicate)
//
//            let sortDescriptor = NSSortDescriptor(key: "lastEnrolledAt", ascending: true)
//            sortDescriptors.append(sortDescriptor)
//
//        }
//
//        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
//
//        if trimmedFilterText.isEmpty == false {
//            let hostNamePredicate = NSPredicate(format: "computerName CONTAINS[c] %@", trimmedFilterText)
//            let serialNumberPredicate = NSPredicate(format: "hardwareSerial CONTAINS[c] %@", trimmedFilterText)
//            let combinedPredicate = NSCompoundPredicate(
//                orPredicateWithSubpredicates: [hostNamePredicate, serialNumberPredicate]
//            )
//
//            predicates.append(combinedPredicate)
//        }
//
//        if filterTokens.isEmpty == false {
//            var platformPredicates = [NSPredicate]()
//            for filterToken in filterTokens {
//                for platform in filterToken.platform {
//                    let tokenPredicate = NSPredicate(format: "platform CONTAINS[c] %@", platform)
//                    platformPredicates.append(tokenPredicate)
//                }
//            }
//            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: platformPredicates)
//            predicates.append(combinedPredicate)
//        }
//
//        if filterStatus != .all {
//            if filterStatus == .online {
//                let statusFilter = NSPredicate(format: "status CONTAINS[c] %@", "online")
//                predicates.append(statusFilter)
//            }
//            if filterStatus == .offline {
//                let statusFilter = NSPredicate(format: "status CONTAINS[c] %@", "offline")
//                predicates.append(statusFilter)
//            }
//            if filterStatus == .missing {
//                // swiftlint:disable:next line_length
//                let statusFilter = NSPredicate(format: "seenTime < %@", Date.now.addingTimeInterval(86400 * -30) as NSDate)
//                predicates.append(statusFilter)
//            }
//            if filterStatus == .recentlyEnrolled {
//                // swiftlint:disable:next line_length
//                let statusFilter = NSPredicate(format: "lastEnrolledAt > %@", Date.now.addingTimeInterval(86400 * -7) as NSDate)
//                predicates.append(statusFilter)
//            }
//        }
//
//        let request = Host.fetchRequest()
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortOldestFirst)]
//        let allHosts = (try? container.viewContext.fetch(request)) ?? []
//        return allHosts
//    }

    func loginWithEmail(
        email: String,
        password: String,
        serverURL: String,
        networkManager: NetworkManager
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

            deleteAll()

            await MainActor.run {
                updateCache(with: user, downloadedTeams: teams)
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

    func loginWithApiKey(apiKey: String, serverURL: String, networkManager: NetworkManager) async throws {
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

            deleteAll()

            await MainActor.run {
                updateCache(with: user, downloadedTeams: teams)
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

    func signOut() async {
        deleteAll()
        activeEnvironment = nil
        isAuthenticated = false
        teamsLastUpdatedAt = nil
        selectedTeam = nil

        do {
            _ = try await NetworkManager(authManager: AuthManager()).fetch(.logout)
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

        UserDefaults.standard.setValue(cachedUser.id, forKey: "loggedInUserID")

        for team in downloadedTeams {
            let cachedTeam = CachedTeam(context: viewContext)
            cachedTeam.id = Int16(team.id)
            cachedTeam.name = team.name
            cachedTeam.role = team.role

            cachedUser.addToTeams(cachedTeam)
        }

        print(cachedUser.teamsArray)
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
    // swiftlint:disable:next file_length

    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        taskContext.undoManager = nil
        return taskContext
    }
}
