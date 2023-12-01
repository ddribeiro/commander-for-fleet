//
//  HostsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct HostsView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<CachedHost.ID> = []

    let smartFilters: [Filter] = [.all, .recentlyEnrolled]

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
        .onAppear {
            dataController.filterText = ""
        }
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
            let cachedHost = CachedHost(context: moc)

            cachedHost.id = Int16(downloadedHost.id)
            cachedHost.platform = downloadedHost.platform
            cachedHost.lastEnrolledAt = downloadedHost.lastEnrolledAt
            cachedHost.seenTime = downloadedHost.seenTime
            cachedHost.uuid = downloadedHost.uuid
            cachedHost.osVersion = downloadedHost.osVersion
            cachedHost.uptime = Int64(downloadedHost.uptime)
            cachedHost.memory = Int64(downloadedHost.memory)
            cachedHost.cpuBrand = downloadedHost.cpuBrand
            cachedHost.hardwareModel = downloadedHost.hardwareModel
            cachedHost.hardwareSerial = downloadedHost.hardwareSerial
            cachedHost.computerName = downloadedHost.computerName
            cachedHost.publicIp = downloadedHost.publicIp
            cachedHost.primaryIp = downloadedHost.primaryIp
            cachedHost.primaryMac = downloadedHost.primaryMac
            cachedHost.teamId = Int16(downloadedHost.teamId ?? 0)
            cachedHost.gigsDiskSpaceAvailable = downloadedHost.gigsDiskSpaceAvailable
            cachedHost.percentDiskSpaceAvailable = Double(downloadedHost.percentDiskSpaceAvailable)
            cachedHost.diskEncryptionEnabled = downloadedHost.diskEncryptionEnabled ?? false
            cachedHost.status = downloadedHost.status
            cachedHost.teamName = downloadedHost.teamName
        }

        try? moc.save()
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
            let cachedTeam = CachedTeam(context: moc)

            cachedTeam.hostCount = Int16(downloadedTeam.hostCount ?? 0)
            cachedTeam.id = Int16(downloadedTeam.id)
            cachedTeam.name = downloadedTeam.name
            cachedTeam.role = downloadedTeam.role
        }

        try? moc.save()
    }
}

#Preview {
    HostsView()
}
