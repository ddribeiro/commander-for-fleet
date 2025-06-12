//
//  NewSideBarView.swift
//  FleetDMViewer
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

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    @State private var showingSettings = false

    var body: some View {
        List(selection: $selection) {
            Section(header: Text("All Teams")) {
                TopLevelNavigationView()
            }
            .headerProminence(.increased)

//            Section(header: Text("Teams")) {
//                Text("No Team")
//                ForEach(teams) { team in
//                    NavigationLink(team.wrappedName) {
//                        TeamView(team: team)
//                    }
//                }
//            }
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

struct Sidebar_Previews: PreviewProvider {
    struct Preview: View {
        @State private var selection: Panel? = Panel.hosts
        var body: some View {
            Sidebar(selection: $selection)
        }
    }

    static var previews: some View {
        NavigationSplitView {
            Preview()
        } detail: {
            Text("Detail!")
        }
    }
}
