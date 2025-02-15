//
//  AllPoliciesView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftUI

struct AllPoliciesView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var policies : [Policy] = []
    @State private var selection: Set<Policy.ID> = []
    @State private var searchText = ""

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.wrappedName, icon: "person.3", team: team)
        }
    }

    var searchResults: [Policy] {
        if searchText.isEmpty {
            return policies
        } else {
            return policies.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
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
                AllPoliciesTableView(selection: $selection, searchText: $searchText, polices: policies)
            }
        }
        .navigationDestination(for: Policy.self) { policy in
            PolicyDetailView(policy: policy)
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Policies" : dataController.selectedFilter.name)
        .task {
            if let policiesLastUpdatedAt = dataController.policiesLastUpdatedAt {
                guard policiesLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
                for team in teamFilters {
                    await fetchTeamPolicies(id: team.id)
                }
                await fetchGlobalPolicies()
            } else {
                for team in teamFilters {
                    await fetchTeamPolicies(id: team.id)
                }
                await fetchGlobalPolicies()
            }
        }
        .refreshable {
            for team in teamFilters {
                await fetchTeamPolicies(id: team.id)
            }
            await fetchGlobalPolicies()
        }
        .onChange(of: dataController.selectedFilter) {
            guard dataController.selectedFilter != .all else { return }
            Task {
                await fetchTeamPolicies(id: dataController.selectedFilter.id)
            }
        }
        .overlay {
            if policies.isEmpty {
                ContentUnavailableView.search
            }
        }
        .searchable(text: $searchText)
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Team", selection: $dataController.selectedFilter) {
                        Text("All Policies").tag(Filter.all)
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
                        if let updatedAt = dataController.policiesLastUpdatedAt {
                            Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                        }

                        Text("^[\(searchResults.count) Policy](inflect: true)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if dataController.loadingState == .loading {
                    HStack {
                        ProgressView()
                            .padding(.horizontal, 1)
                            .controlSize(.mini)

                        Text("Loading Policies")
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
            policyRows(searchResults)
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

    func fetchTeamPolicies(id: Int) async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            dataController.loadingState = .loading
            policies = try await networkManager.fetch(.getTeamPolicies(id: id)).policies


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

    func fetchGlobalPolicies() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            policies = try await networkManager.fetch(.globalPolicies, attempts: 5).policies
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
}
