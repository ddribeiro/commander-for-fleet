//
//  Sidebar.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/28/23.
//

import SwiftUI

enum Panel: Hashable {
    case home
    case hosts
    case controls
    case users
    case queries
    case policies
    case software
}

struct Sidebar: View {
    @Binding var selection: Panel?

    @EnvironmentObject var dataController: DataController
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showingSettings = false

    var body: some View {
        List(selection: $selection) {
            Section(header: Text("All Teams")) {
                TopLevelNavigationView()
            }
            .headerProminence(.increased)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "person.crop.circle")
                }
            }
        }
        .navigationTitle("Home")
    }
}

#Preview {
    NavigationSplitView {
        Sidebar(selection: .constant(Panel.hosts))
    } detail: {
        Text("Detail!")
    }
    .environmentObject(DataController(networkManager: NetworkManager(authManager: AuthManager())))
}
