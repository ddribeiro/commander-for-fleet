//
//  HostsListView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftData
import SwiftUI
import KeychainWrapper

struct HostsListView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.modelContext) var modelContext
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false

    @Query var teams: [CachedTeam]
    @Query var hosts: [CachedHost]

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.name, icon: "person.3", team: team)
        }
    }

    var body: some View {
        if dataController.isAuthenticated {
            List {
                ForEach(hosts) { host in
                    HostRow(host: host)
                }
            }
            .overlay {
                if hosts.isEmpty {
                    ContentUnavailableView.search
                }
            }
            .toolbar {
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
        } else {
            NoHostView()
                .sheet(isPresented: $isShowingSignInSheet) {
                    LoginView()
                }
                .onAppear {
                    isShowingSignInSheet = true
                }
        }
    }

    init(
        searchText: String,
        filter: Filter,
        sortOptions: SortOptions
    ) {
        let predicate = CachedHost.predicate(searchText: searchText, filter: filter, sortOptions: sortOptions)

        switch sortOptions.selectedSortType {
        case .name:
            if sortOptions.selectedSortOrder == .forward {
                _hosts = Query(filter: predicate, sort: \.computerName, order: .forward)
            } else {
                _hosts = Query(filter: predicate, sort: \.computerName, order: .reverse)
            }
        case .enolledDate:
            if sortOptions.selectedSortOrder == .forward {
                _hosts = Query(filter: predicate, sort: \.lastEnrolledAt, order: .forward)
            } else {
                _hosts = Query(filter: predicate, sort: \.lastEnrolledAt, order: .reverse)
            }
        case .updatedDate:
            if sortOptions.selectedSortOrder == .forward {
                _hosts = Query(filter: predicate, sort: \.seenTime, order: .forward)
            } else {
                _hosts = Query(filter: predicate, sort: \.seenTime, order: .reverse)
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
