//
//  UserView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftData
import SwiftUI

struct UsersView: View {
    @EnvironmentObject var dataController: DataController
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<CachedUser.ID> = []
    @State private var searchText = ""

    @Query var users: [CachedUser]
    @Query var teams: [CachedTeam]
//    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var users: FetchedResults<CachedUser>
//    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    var displayAsList: Bool {
#if os(iOS)
        return sizeClass == .compact
#else
        return false
#endif
    }

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.name, icon: "person.3", team: team)
        }
    }

    var searchResults: [CachedUser] {
        if searchText.isEmpty {
            return dataController.usersForSelectedFilter()
        } else {
            return dataController.usersForSelectedFilter().filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ZStack {
            if displayAsList {
                list
            } else {
                UsersTableView(selection: $selection, searchText: $searchText)
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
            text: $searchText
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
                if dataController.loadingState == .loaded {

                    VStack {
                        if let updatedAt = dataController.usersLastUpdatedAt {
                            Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                            Text("^[\(searchResults.count) User](inflect: true)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if dataController.loadingState == .loading {
                    HStack {
                        ProgressView()
                            .padding(.horizontal, 1)
                            .controlSize(.mini)

                        Text("Loading Users")
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
            userRows(searchResults)
            }
        }

    func userRows(_ users: [CachedUser]) -> some View {
        ForEach(users) { user in
            NavigationLink(value: user) {
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

    func fetchUsers() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            dataController.loadingState = .loading
            let users = try await networkManager.fetch(.users, attempts: 5)

            await MainActor.run {
                updateCache(with: users)
                dataController.usersLastUpdatedAt = .now
            }
            dataController.loadingState = .loaded

        } catch {
            dataController.loadingState = .failed
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
            let cachedUser = CachedUser(
                apiOnly: downloadedUser.apiOnly,
                createdAt: downloadedUser.createdAt,
                email: downloadedUser.email,
                gravatarUrl: downloadedUser.gravatarUrl,
                id: downloadedUser.id,
                name: downloadedUser.name,
                ssoEnabled: downloadedUser.ssoEnabled,
                updatedAt: downloadedUser.updatedAt,
                teams: []
            )

            for team in downloadedUser.teams {
                let cachedTeam = CachedTeam(
                    id: team.id,
                    name: team.name,
                    role: team.role
                )
                
                cachedUser.teams.append(cachedTeam)
            }
            
            modelContext.insert(cachedUser)
        }
    }
}

#Preview {
    UsersView()
}
