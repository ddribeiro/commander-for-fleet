//
//  FleetDMViewerApp.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/2/23.
//

import SwiftUI

@main
struct FleetDMViewerApp: App {
    @StateObject var dataController = DataController()
    @State var networkManager = NetworkManager(authManager: AuthManager())

    var body: some Scene {
        WindowGroup {
            if dataController.isAuthenticated {
                NavigationSplitView {
                    SidebarView()
                } content: {
                    ContentView()
                } detail: {
                    DetailView()
                }
                .environmentObject(dataController)
                .environment(\.networkManager, networkManager)
                .environment(\.managedObjectContext, dataController.container.viewContext)
            } else {
                SignedOutView()
                    .environmentObject(dataController)
                    .environment(\.networkManager, networkManager)
                    .environment(\.managedObjectContext, dataController.container.viewContext)

            }
        }
    }
}
