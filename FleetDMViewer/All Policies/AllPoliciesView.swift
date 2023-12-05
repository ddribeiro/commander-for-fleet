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

    @State private var selection: Set<CachedPolicy.ID> = []

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.wrappedName, icon: "person.3", team: team)
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
                EmptyView()
            } else {
                AllPoliciesTableView(selection: $selection)
            }
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Policies" : dataController.selectedFilter.name)
        .task {
            if let policiesLastUpdatedAt = dataController.policiesLastUpdatedAt {
                guard policiesLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
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
            if dataController.policiesforSelectedFilter().isEmpty {
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
                if let updatedAt = dataController.policiesLastUpdatedAt {
                    VStack {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                        Text("^[\(dataController.policiesforSelectedFilter().count) Policy](inflect: true)")
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

    func fetchTeamPolicies(id: Int) async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            let policies = try await networkManager.fetch(.getTeamPolicies(id: id))

            await MainActor.run {
                updateCache(with: policies)
                dataController.policiesLastUpdatedAt = .now
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

    func fetchGlobalPolicies() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            let policies = try await networkManager.fetch(.globalPolicies, attempts: 5)

            await MainActor.run {
                updateCache(with: policies)
                dataController.policiesLastUpdatedAt = .now
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

    func updateCache(with downloadedPolicies: [Policy]) {
        for downloadedPolicy in downloadedPolicies {
            let cachedPolicy = CachedPolicy(context: moc)

            cachedPolicy.id = Int16(downloadedPolicy.id)
            cachedPolicy.name = downloadedPolicy.name
            cachedPolicy.query = downloadedPolicy.query
            cachedPolicy.critical = downloadedPolicy.critical
            cachedPolicy.policyDescription = downloadedPolicy.description
            cachedPolicy.authorId = Int16(downloadedPolicy.authorId)
            cachedPolicy.authorName = downloadedPolicy.authorName
            cachedPolicy.authorEmail = downloadedPolicy.authorEmail
            cachedPolicy.teamId = Int16(downloadedPolicy.teamId)
            cachedPolicy.resolution = downloadedPolicy.resolution
            cachedPolicy.platform = downloadedPolicy.platform
            cachedPolicy.createdAt = downloadedPolicy.createdAt
            cachedPolicy.updatedAt = downloadedPolicy.updatedAt
            cachedPolicy.passingHostCount = Int16(downloadedPolicy.passingHostCount ?? 0)
            cachedPolicy.failingHostCount = Int16(downloadedPolicy.failingHostCount ?? 0)

        }
        try? moc.save()
    }
}

#Preview {
    AllPoliciesView()
}
