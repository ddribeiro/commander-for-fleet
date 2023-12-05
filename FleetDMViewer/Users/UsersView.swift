//
//  UserView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct UsersView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<CachedUser.ID> = []

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var users: FetchedResults<CachedUser>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    var displayAsList: Bool {
#if os(iOS)
        return sizeClass == .compact
#else
        return false
#endif
    }

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.wrappedName, icon: "person.3", team: team)
        }
    }

    var body: some View {
        ZStack {
            if displayAsList {
                UsersListView()
            } else {
                UsersTableView(selection: $selection)
            }
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Users" : dataController.selectedFilter.name)
        .navigationDestination(for: CachedUser.self) { user in
            UserDetailView(user: user)
        }
        .task {
            if let usersLastUpdatedAt = dataController.usersLastUpdatedAt {
                guard usersLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
            }
            await fetchUsers()
        }
        .refreshable {
            await fetchUsers()
        }
        .overlay {
            if dataController.usersForSelectedFilter().isEmpty {
                ContentUnavailableView.search
            }
        }
        .searchable(
            text: $dataController.filterText
        )
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Team", selection: $dataController.selectedFilter) {
                        Text("All Users").tag(Filter.all)
                        Divider()
                        ForEach(teamFilters) { filter in
                            Text(filter.name).tag(filter).badge(filter.hostCount)
                        }
                    }
                } label: {
                    Label("Teams", systemImage: "person.3")
                        .symbolVariant(dataController.selectedFilter != .all ? .fill : .none)
                }
            }

            ToolbarItem(placement: .bottomBar) {
                if let updatedAt = dataController.usersLastUpdatedAt {
                    VStack {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                        Text("^[\(dataController.usersForSelectedFilter().count) Users](inflect: true)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
#endif
    }

    @ViewBuilder
    var toolbarButtons: some View {
        NavigationLink(value: selection.first) {
            Label("View Details", systemImage: "list.bullet.below.rectangle")
        }
        .disabled(selection.isEmpty)
    }

    func fetchUsers() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            let users = try await networkManager.fetch(.users, attempts: 5)

            await MainActor.run {
                updateCache(with: users)
                dataController.usersLastUpdatedAt = .now
            }

        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error.localizedDescription)
            case .none:
                print(error.localizedDescription)
            }
        }
    }

    func updateCache(with downloadedUsers: [User]) {
        for downloadedUser in downloadedUsers {
            let cachedUser = CachedUser(context: moc)

            cachedUser.createdAt = downloadedUser.createdAt
            cachedUser.updatedAt = downloadedUser.updatedAt
            cachedUser.id = Int16(downloadedUser.id)
            cachedUser.name = downloadedUser.name
            cachedUser.email = downloadedUser.email
            cachedUser.gravatarUrl = downloadedUser.gravatarUrl
            cachedUser.ssoEnabled = downloadedUser.ssoEnabled
            cachedUser.globalRole = downloadedUser.globalRole
            cachedUser.apiOnly = downloadedUser.apiOnly

            cachedUser.removeFromTeams(cachedUser.teams ?? [] as NSSet)

            for team in downloadedUser.teams {
                let cachedTeam = CachedTeam(context: moc)
                cachedTeam.id = Int16(team.id)
                cachedTeam.name = team.name

                cachedUser.addToTeams(cachedTeam)

            }
        }

        try? moc.save()
    }
}

#Preview {
    UsersView()
}
