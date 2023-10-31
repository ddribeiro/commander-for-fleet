//
//  DataController.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/21/23.
//

import CoreData
import Foundation
import SwiftUI

enum SortType: String {
    case com
}

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "FleetDMViewer")

    @Published var selectedFilter: Filter?
    @Published var filterText = ""
    @Published var filterTokens = [Token]()

    @Published var selectedTeam: CachedTeam?
    @Published var selectedHost: CachedHost?
    @Published var activeEnvironment: AppEnvironment?

    @Published var teamsLastUpdatedAt: Date?
    @Published var hostsLastUpdatedAt: Date?

    @Published var allTokens = [
        Token(name: "macOS", platform: ["darwin"]),
        Token(name: "Windows", platform: ["windows"]),
        Token(name: "Linux", platform: ["rhel", "ubuntu"])
    ]

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

    func saveActiveEnvironment(environment: AppEnvironment) {
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
}
