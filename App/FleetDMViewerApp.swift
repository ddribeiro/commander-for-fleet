//
//  FleetDMViewerApp.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/2/23.
//

import SwiftData
import SwiftUI

@main
struct FleetDMViewerApp: App {
    @StateObject var dataController = DataController()
    @State var networkManager = NetworkManager(authManager: AuthManager())

    @State private var selection: Panel? = Panel.hosts

    var body: some Scene {
        WindowGroup {
            if dataController.isAuthenticated {
                ContentView()
            } else {
                SignedOutView()
            }
        }
        .environmentObject(dataController)
        .environment(\.networkManager, networkManager)
        .modelContainer(for: [
            CachedHost.self,
            CachedTeam.self,
            CachedUser.self,
            CachedSoftware.self,
            CachedPolicy.self
            ])
    }
}
