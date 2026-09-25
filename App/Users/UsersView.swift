//
//  UserView.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct UsersView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<User.ID> = []

    var teamFilters: [Filter] {
        dataController.teams.map { team in
            Filter(id: team.id, name: team.name, icon: "person.2", team: team)
        }
    }

    var displayAsList: Bool {
        #if os(iOS)
        return sizeClass == .compact
        #else
        return false
        #endif
    }

    var body: some View {
        ZStack {
            if displayAsList {
                list
            } else {
                UsersTableView(selection: $selection)
            }
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Users" : dataController.selectedFilter.name)
        .navigationDestination(for: User.ID.self) { id in
            UserDetailView(id: id)
        }
        .toolbar {
            if !displayAsList {
                toolbarButtons
            }
        }
        .task {
            if let usersLastUpdatedAt = dataController.usersLastUpdatedAt {
                guard usersLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
            }
            await dataController.updateUsers()
        }
        .overlay {
            let filtered = dataController.usersForSelectedFilter()
            if filtered.isEmpty {
                if dataController.loadingState == .loading {
                    ProgressView("Loading Users…")
                } else if dataController.usersLastUpdatedAt != nil {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        "No Users Found",
                        systemImage: "person.2.slash",
                        description: Text("Pull to refresh to try again.")
                    )
                }
            }
        }
        .searchable(
            text: $dataController.filterText
        )
        .refreshable {
            await dataController.updateUsers()
        }
        .sheet(isPresented: $dataController.showingApiTokenAlert) {
            APITokenRefreshView()
                .presentationDetents([.medium])
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Team", selection: $dataController.selectedFilter) {
                        Text("All Users").tag(Filter.all)
                        Divider()
                        ForEach(teamFilters) { filter in
                            Text(filter.name).tag(filter)
                        }
                    }
                } label: {
                    Label("Teams", systemImage: "person.2")
                        .symbolVariant(dataController.selectedFilter != .all ? .fill : .none)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ContentViewToolbar()
            }

            ToolbarItem(placement: .bottomBar) {
                if let updatedAt = dataController.usersLastUpdatedAt {
                    VStack {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                        Text("^[\(dataController.usersForSelectedFilter().count) User](inflect: true)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
#endif
    }

    var list: some View {
        List {
            userRows(dataController.usersForSelectedFilter())
        }
    }

    func userRows(_ users: [User]) -> some View {
        ForEach(users) { user in
            NavigationLink(value: user.id) {
                UserRow(user: user)
            }
        }
    }

    @ViewBuilder
    var toolbarButtons: some View {
        NavigationLink(value: selection.first) {
            Label("View Details", systemImage: "list.bullet.below.rectangle")
        }
        .disabled(selection.isEmpty)
    }
}

#Preview {
    UsersView()
        .environmentObject(
            DataController(networkManager: NetworkManager(authManager: AuthManager()))
        )
}
