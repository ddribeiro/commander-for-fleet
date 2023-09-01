//
//  TeamView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 5/30/23.
//

import SwiftUI
import KeychainWrapper

struct TeamsView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController

    let smartFilters: [Filter] = [.all]

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    @StateObject var appEnvironments = AppEnvironments()

    @State private var showingSettings = false
    @State private var showingLogin = false

    @State private var teamsLastUpdatedAt: Date?

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.wrappedName, icon: "person.3", team: team)
        }
    }

    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }

            Section("Teams") {
                ForEach(teamFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.hostCount)
                            .lineLimit(1)
                    }
                }
            }
        }
        .task {
            guard teams.isEmpty else { return }
            if let teamsLastUpdatedAt = teamsLastUpdatedAt {
                guard teamsLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
            }
            await fetchTeams()
        }
        .refreshable {
            await fetchTeams()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingLogin, content: LoginView.init)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showingSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "person.crop.circle")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showingLogin.toggle()
                } label: {
                    Label("Login", systemImage: "network")
                }
            }
        }
        .navigationTitle("Teams")
    }

    func fetchTeams() async {

        guard let serverURL = KeychainWrapper.default.string(forKey: "serverURL") else {
            print("Could not get server URL")
            return
        }

        let environment = AppEnvironment(baseURL: URL(string: "\(serverURL)")!)
        let networkManager = NetworkManager(environment: environment)

        do {
            let teams = try await networkManager.fetch(.teams)
            let hosts = try await networkManager.fetch(.hosts)

            await MainActor.run {
                updateCache(with: teams, hosts)
                teamsLastUpdatedAt = Date.now
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateCache(with downloadedTeams: [Team], _ downloadedHosts: [Host]) {
        for downloadedTeam in downloadedTeams {
            let cachedTeam = CachedTeam(context: moc)

            cachedTeam.hostCount = Int16(downloadedTeam.hostCount ?? 0)
            cachedTeam.id = Int16(downloadedTeam.id)
            cachedTeam.name = downloadedTeam.name
        }

        try? moc.save()
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
            .environmentObject(DataController())
    }
}
