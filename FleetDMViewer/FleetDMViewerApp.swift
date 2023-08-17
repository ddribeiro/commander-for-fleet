//
//  FleetDMViewerApp.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/2/23.
//

import SwiftUI

@main
struct FleetDMViewerApp: App {
    @StateObject var viewModel = ViewModel()
    @State private var searchText = ""

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                TeamsView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environmentObject(viewModel)
        }
    }
}
