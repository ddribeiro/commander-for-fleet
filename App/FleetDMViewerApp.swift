//
//  FleetDMViewerApp.swift
//  Commander
//
//  Created by Dale Ribeiro on 5/22/23.
//

import SwiftUI

@main
struct FleetDMViewerApp: App {
    // The core services, wired up once here and shared across the app.
    @StateObject private var authService: AuthService
    @State private var networkManager: NetworkManager
    @StateObject private var dataController: DataController

    init() {
        let auth = AuthManager()
        let network = NetworkManager(authManager: auth)
        let data = DataController(networkManager: network)

        // Use wrappedValue for State/StateObject initialization in init.
        _networkManager = State(wrappedValue: network)
        _authService = StateObject(
            wrappedValue: AuthService(authManager: auth, networkManager: network, dataController: data)
        )
        _dataController = StateObject(wrappedValue: data)
    }

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                ContentView()
                    .environment(\.networkManager, networkManager)
            } else {
                SignedOutView()
                    .environment(\.networkManager, networkManager)
            }
        }
        .environmentObject(authService)
        .environmentObject(dataController)
    }
}
