//
//  FleetDMViewerApp.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/2/23.
//

import SwiftUI

@main
struct FleetDMViewerApp: App {
    @State var dataController = DataController()
    @State private var networkManager = NetworkManager(environment: DataController().activeEnvironment)

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
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environment(\.networkManager, networkManager)
        }
    }
}
