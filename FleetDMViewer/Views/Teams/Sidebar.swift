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

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var users: FetchedResults<CachedUser>

    let smartFilters: [Filter] = [.all, .recentlyEnrolled]

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    @State private var showingSettings = false
    @State private var showingLogin = false

    @State private var smartFiltersExpanded = true
    @State private var teamsFilterExpanded = true

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.wrappedName, icon: "person.3", team: team)
        }
    }

    var body: some View {
        List(selection: $selection) {

            Section {
                NavigationLink(value: Panel.hosts) {
                    Label("Hosts", systemImage: "laptopcomputer")
                }
                if let savedUserID = UserDefaults.standard.value(forKey: "loggedInUserID") as? Int16 {
                if let loggedInUser = users.first(where: { $0.id == savedUserID}) {
                    if loggedInUser.globalRole == "admin" {
                        NavigationLink(value: Panel.users) {
                            Label("Users", systemImage: "person.3")
                        }
                    }
                    }
                }

                NavigationLink(value: Panel.software) {
                    Label("Software", systemImage: "app.badge")
                }

                NavigationLink(value: Panel.queries) {
                    Label("Queries", systemImage: "rectangle.and.text.magnifyingglass")
                }

                NavigationLink(value: Panel.policies) {
                    Label("Policies", systemImage: "checkmark.seal")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $dataController.showingApiTokenAlert) {
            APITokenRefreshView()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingLogin, content: LoginView.init)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "person.crop.circle")
                }
            }

            if UIDevice.current.userInterfaceIdiom == .phone {
                ToolbarItem(placement: .bottomBar) {
                    if let updatedAt = dataController.teamsLastUpdatedAt {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                    }
                }
            }
        }
        .navigationTitle("Commander")
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
