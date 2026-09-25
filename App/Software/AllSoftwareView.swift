//
//  SoftwareView.swift
//  Commander
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftUI

struct AllSoftwareView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<Software.ID> = []
    @State private var isShowingVulnerableSoftware = false

    var teamFilters: [Filter] {
        dataController.teams.map { team in
            Filter(id: team.id, name: team.name, icon: "square.grid.2x2", team: team)
        }
    }

    var softwareResults: [Software] {
        var results = dataController.softwareForSelectedFilter()

        if isShowingVulnerableSoftware {
            results = results.filter { !($0.vulnerabilities ?? []).isEmpty }
        }

        return results
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
                AllSoftwareTableView(
                    selection: $selection,
                    isShowingVulnerableSoftware: $isShowingVulnerableSoftware
                )
            }
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Software" : dataController.selectedFilter.name)
        .navigationDestination(for: Software.self) { software in
            SoftwareDetailView(software: software)
        }
        .toolbar {
            if !displayAsList {
                toolbarButtons
            }
        }
        .task {
            let requestedTeamId = dataController.selectedFilter.team?.id

            if let softwareLastUpdatedAt = dataController.softwareLastUpdatedAt,
               dataController.softwareTeamId == requestedTeamId {
                guard softwareLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
            }

            await dataController.updateSoftware(teamId: requestedTeamId)
        }
        .refreshable {
            await dataController.updateSoftware(teamId: dataController.selectedFilter.team?.id)
        }
        .onChange(of: dataController.selectedFilter) { _ in
            Task {
                await dataController.updateSoftware(teamId: dataController.selectedFilter.team?.id)
            }
        }
        .overlay {
            if softwareResults.isEmpty {
                if dataController.loadingState == .loading {
                    ProgressView("Loading Software…")
                } else if dataController.softwareLastUpdatedAt != nil {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        "No Software Found",
                        systemImage: "app.slash",
                        description: Text("Pull to refresh to try again.")
                    )
                }
            }
        }
        .searchable(
            text: $dataController.filterText
        )
        .sheet(isPresented: $dataController.showingApiTokenAlert) {
            APITokenRefreshView()
                .presentationDetents([.medium])
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingVulnerableSoftware.toggle()
                } label: {
                    Label("Show Vulnerable Software", systemImage: "exclamationmark.shield")
                        .symbolVariant(isShowingVulnerableSoftware ? .fill : .none)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Team", selection: $dataController.selectedFilter) {
                        Text("All Software").tag(Filter.all)
                        Divider()
                        ForEach(teamFilters) { filter in
                            Text(filter.name).tag(filter)
                        }
                    }
                } label: {
                    Label("Teams", systemImage: "square.grid.2x2")
                        .symbolVariant(dataController.selectedFilter != .all ? .fill : .none)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ContentViewToolbar()
            }

            ToolbarItem(placement: .bottomBar) {
                if let updatedAt = dataController.softwareLastUpdatedAt {
                    VStack {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                        Text("^[\(softwareResults.count) Software Titles](inflect: true)")
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
            softwareRows(softwareResults)
        }
    }

    func softwareRows(_ software: [Software]) -> some View {
        ForEach(software) { software in
            NavigationLink(value: software) {
                AllSoftwareRow(software: software)
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
    AllSoftwareView()
        .environmentObject(
            DataController(networkManager: NetworkManager(authManager: AuthManager()))
        )
}
