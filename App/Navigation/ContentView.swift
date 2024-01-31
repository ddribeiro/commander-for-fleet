//
//  ContentView2.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI
import KeychainWrapper

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var selection: Panel? = Panel.hosts
    @State private var path = NavigationPath()

    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selection)
        } detail: {
            NavigationStack(path: $path) {
                DetailColumn(selection: $selection)
            }
        }
    }
}
