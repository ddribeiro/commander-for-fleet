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

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>
    //    @State private var teams = [Team]()
    @StateObject var appEnvironments = AppEnvironments()

    @State private var showingSettings = false
    @State private var showingLogin = false

    var body: some View {
        List(selection: $dataController.selectedTeam) {
            Section("All Hosts") {
                NavigationLink {
                    ContentView()
                } label: {
                    Label("All Hosts", systemImage: "laptopcomputer")
                }
            }

            Section("Teams") {
                ForEach(teams) { team in
                    NavigationLink(value: team) {
                        Label(team.wrappedName, systemImage: "person.3")
                            .badge(Int(team.hostCount))
                            .lineLimit(1)
                    }
                }
            }
        }
        .task {
            guard teams.isEmpty else { return }
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
            updateCache(with: teams, hosts)
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
