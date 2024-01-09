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

    @State private var selection: Set<CachedHost.ID> = []

    let smartFilters: [Filter] = [.all, .recentlyEnrolled]

//    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>
    @Query var teams: [CachedTeam]

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
                HostsListView()
            } else {
                HostsTable(selection: $selection)
            }
        }
        .navigationTitle(dataController.selectedFilter == .all ? "All Hosts" : dataController.selectedFilter.name)
        .navigationDestination(for: CachedHost.ID.self) { id in
            HostView(id: id)
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
            await fetchTeams()
            await fetchHosts()
        }
//        .onAppear {
//            dataController.filterText = ""
//        }
        .overlay {
            if dataController.hostsForSelectedFilter().isEmpty {
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
            await fetchHosts()
            await fetchTeams()
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
                        Text("^[\(dataController.hostsForSelectedFilter().count) Computers](inflection: true)")
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

    func fetchHosts() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            let hosts = try await networkManager.fetch(.hosts, attempts: 5)

            await MainActor.run {
                updateCache(with: hosts)
                dataController.hostsLastUpdatedAt = .now
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

    func updateCache(with downloadedHosts: [Host]) {
        for downloadedHost in downloadedHosts {
            let cachedHost = CachedHost(computerName: downloadedHost.computerName, cpuBrand: downloadedHost.cpuBrand, gigsDiskSpaceAvailable: downloadedHost.gigsDiskSpaceAvailable, hardwareModel: downloadedHost.hardwareModel, hardwareSerial: downloadedHost.hardwareSerial, id: downloadedHost.id, lastEnrolledAt: downloadedHost.lastEnrolledAt, memory: downloadedHost.memory, osVersion: downloadedHost.osVersion, percentDiskSpaceAvailable: downloadedHost.percentDiskSpaceAvailable, platform: downloadedHost.platform, primaryIp: downloadedHost.primaryIp, primaryMac: downloadedHost.primaryMac, publicIp: downloadedHost.publicIp, seenTime: downloadedHost.seenTime, status: downloadedHost.status, teamId: downloadedHost.teamId ?? 0, teamName: downloadedHost.teamName ?? "", uptime: downloadedHost.uptime, uuid: downloadedHost.uuid)
            
            modelContext.insert(cachedHost)
        }
    }

    func fetchTeams() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            let teams = try await networkManager.fetch(.teams, attempts: 5)

            await MainActor.run {
                updateCache(with: teams)
                dataController.teamsLastUpdatedAt = .now
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

    func updateCache(with downloadedTeams: [Team]) {
        for downloadedTeam in downloadedTeams {
            let cachedTeam = CachedTeam(hostCount: downloadedTeam.hostCount ?? 0, id: downloadedTeam.id, name: downloadedTeam.name, role: downloadedTeam.role)
            
            modelContext.insert(cachedTeam)
        }
    }
}

#Preview {
    HostsView()
}
