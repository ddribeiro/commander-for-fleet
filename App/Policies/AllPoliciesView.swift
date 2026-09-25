//
//  AllPoliciesView.swift
//  Commander
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftUI

struct AllPoliciesView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<Policy.ID> = []

    var teamFilters: [Filter] {
        dataController.teams.map { team in
            Filter(id: team.id, name: team.name, icon: "checkmark.seal", team: team)
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
                AllPoliciesTableView(selection: $selection)
            }
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Policies" : dataController.selectedFilter.name)
        .navigationDestination(for: Policy.self) { policy in
            PolicyDetailView(policy: policy)
        }
        .toolbar {
            if !displayAsList {
                toolbarButtons
            }
        }
        .task {
            if let policiesLastUpdatedAt = dataController.policiesLastUpdatedAt {
                guard policiesLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
            }
            await dataController.updateTeams()
            await dataController.updatePolicies()
        }
        .overlay {
            let filtered = dataController.policiesForSelectedFilter()
            if filtered.isEmpty {
                if dataController.loadingState == .loading {
                    ProgressView("Loading Policies…")
                } else if dataController.policiesLastUpdatedAt != nil {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        "No Policies Found",
                        systemImage: "checkmark.seal.slash",
                        description: Text("Pull to refresh to try again.")
                    )
                }
            }
        }
        .searchable(
            text: $dataController.filterText
        )
        .refreshable {
            await dataController.updatePolicies()
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
                        Text("All Policies").tag(Filter.all)
                        Divider()
                        ForEach(teamFilters) { filter in
                            Text(filter.name).tag(filter)
                        }
                    }
                } label: {
                    Label("Teams", systemImage: "checkmark.seal")
                        .symbolVariant(dataController.selectedFilter != .all ? .fill : .none)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ContentViewToolbar()
            }

            ToolbarItem(placement: .bottomBar) {
                if let updatedAt = dataController.policiesLastUpdatedAt {
                    VStack {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                        Text("^[\(dataController.policiesForSelectedFilter().count) Policy](inflect: true)")
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
            policyRows(dataController.policiesForSelectedFilter())
        }
    }

    func policyRows(_ policies: [Policy]) -> some View {
        ForEach(policies) { policy in
            NavigationLink(value: policy) {
                AllPoliciesRow(policy: policy)
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
    AllPoliciesView()
        .environmentObject(
            DataController(networkManager: NetworkManager(authManager: AuthManager()))
        )
}
