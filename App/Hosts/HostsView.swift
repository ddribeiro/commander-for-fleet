//
//  HostsView.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct HostsView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<Host.ID> = []

    var teamFilters: [Filter] {
        dataController.teams.map { team in
            Filter(id: team.id, name: team.name, icon: "person.3", team: team)
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
                HostsTable(selection: $selection)
            }
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Hosts" : dataController.selectedFilter.name)
        .navigationDestination(for: Host.ID.self) { id in
            HostDetailsView(id: id)
        }
        .toolbar {
            if !displayAsList {
                toolbarButtons
            }
        }
        .task {
            if let hostsLastUpdatedAt = dataController.hostsLastUpdatedAt {
                guard hostsLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
            }
            await dataController.updateTeams()
            await dataController.updateHosts()
        }
        .overlay {
            let filtered = dataController.hostsForSelectedFilter()
            if filtered.isEmpty {
                if dataController.loadingState == .loading {
                    ProgressView("Loading Hosts…")
                } else if dataController.hostsLastUpdatedAt != nil {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        "No Hosts Found",
                        systemImage: "laptopcomputer.slash",
                        description: Text("Pull to refresh to try again.")
                    )
                }
            }
        }
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
            suggestedTokens: $dataController.allTokens
        ) { token in
            Text(token.name)
        }
        .refreshable {
            await dataController.updateHosts()
            await dataController.updateTeams()
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
                        Text("All Hosts").tag(Filter.all)
                        Divider()
                        ForEach(teamFilters) { filter in
                            Text(filter.name).badge(filter.hostCount).tag(filter)
                        }
                    }
                } label: {
                    Label("Teams", systemImage: "person.3")
                        .symbolVariant(dataController.selectedFilter != .all ? .fill : .none)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ContentViewToolbar()
            }

            ToolbarItem(placement: .bottomBar) {
                if let updatedAt = dataController.hostsLastUpdatedAt {
                    VStack {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                        Text("^[\(dataController.hostsForSelectedFilter().count) Computers](inflect: true)")
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
            hostRows(dataController.hostsForSelectedFilter())
        }
    }

    func hostRows(_ hosts: [Host]) -> some View {
        ForEach(hosts) { host in
            NavigationLink(value: host.id) {
                HostRow(host: host)
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
    HostsView()
        .environmentObject(
            DataController(networkManager: NetworkManager(authManager: AuthManager()))
        )
}
