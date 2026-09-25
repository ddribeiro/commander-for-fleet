//
//  ContentView.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController

    @State private var selection: Panel?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selection)
        } detail: {
            NavigationStack(path: $path) {
                DetailColumn(selection: $selection)
            }
        }
        .sheet(isPresented: $dataController.showingApiTokenAlert) {
            APITokenRefreshView()
                .presentationDetents([.medium])
        }
    }
}
