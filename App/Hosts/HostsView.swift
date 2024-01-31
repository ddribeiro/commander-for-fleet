//
//  HostsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftData
import SwiftUI

struct HostsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass

//    @State private var selection: Set<CachedHost.ID> = []

    @State private var searchText = ""
    @State private var sortOrder = [SortDescriptor(\CachedHost.computerName)]
    @State private var selectedFilter = Filter.all

    let smartFilters: [Filter] = [.all, .recentlyEnrolled]

    @Query(sort: \CachedTeam.name, order: .reverse) var teams: [CachedTeam]
    @Query var hosts: [CachedHost]

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.name, icon: "person.3", team: team)
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
                HostsListView(searchString: searchText, sortOrder: sortOrder)
            } else {
                HostsTable()
            }
        }
        .navigationTitle(selectedFilter == .all ? "All Hosts" : selectedFilter.name)
        .navigationDestination(for: CachedHost.ID.self) { id in
            HostView(id: id)
        }
//        .toolbar {
//            if !displayAsList {
//                toolbarButtons
//            }
//        }
        .task {
            if let hostsLastUpdatedAt = dataController.hostsLastUpdatedAt {
                guard hostsLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
            }
            await CachedTeam.refresh(modelContext: modelContext, dataController: dataController)
            await CachedHost.refresh(modelContext: modelContext)
        }
        .overlay {
            if hosts.isEmpty {
                ContentUnavailableView.search
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
            await CachedHost.refresh(modelContext: modelContext)
            await CachedTeam.refresh(modelContext: modelContext, dataController: dataController)
        }
        .sheet(isPresented: $dataController.showingApiTokenAlert) {
            APITokenRefreshView()
                .presentationDetents([.medium])
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Team", selection: $selectedFilter) {
                        Text("All Hosts").tag(Filter.all)
                        Divider()
                        ForEach(teamFilters) { filter in
                            Text(filter.name).badge(filter.hostCount).tag(filter)
                        }
                    }
                } label: {
                    Label("Teams", systemImage: "person.3")
                        .symbolVariant(selectedFilter != .all ? .fill : .none)
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
                        Text("^[\(hosts.count) Computers](inflection: true)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
#endif

    }

//    @ViewBuilder
//    var toolbarButtons: some View {
//        NavigationLink(value: selection.first) {
//            Label("View Details", systemImage: "list.bullet.below.rectangle")
//        }
//        .disabled(selection.isEmpty)
//    }
}

#Preview {
    HostsView()
}
