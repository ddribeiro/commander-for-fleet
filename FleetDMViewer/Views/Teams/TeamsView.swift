//
//  TeamView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 5/30/23.
//

import SwiftUI
import KeychainWrapper

struct TeamsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var teams = [Team]()
    @StateObject var appEnvironments = AppEnvironments()

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
                        Label(team.name, systemImage: "person.3")
                            .badge(team.hostCount)
                            .lineLimit(1)
                    }
                }
            }
        }
        .task {
            if teams.isEmpty {
                await fetchTeams()
            }
        }
        .refreshable {
            await fetchTeams()
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
            teams = try await networkManager.fetch(.teams)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
            .environmentObject(DataController())
    }
}
