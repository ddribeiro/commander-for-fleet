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
    @State var networkManager = NetworkManager()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                TeamsView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environmentObject(dataController)
            .environment(\.networkManager, networkManager)
            .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
