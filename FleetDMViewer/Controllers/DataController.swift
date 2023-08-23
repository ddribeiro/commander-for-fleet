//
//  DataController.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/21/23.
//

import CoreData
import Foundation
import SwiftUI

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "FleetDMViewer")

    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }

            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }

    @Published var selectedTeam: Team?
    @Published var selectedHost: Host?
    @Published var currentUser: User?

    @Published var activeEnvironment: AppEnvironment? {
        didSet {
            print(String(describing: activeEnvironment))
        }
    }

    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false

}
