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
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager

    let smartFilters: [Filter] = [.all]

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    @State private var showingSettings = false
    @State private var showingLogin = false

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
            if let teamsLastUpdatedAt = dataController.teamsLastUpdatedAt {
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
        .overlay(alignment: .bottom) {
            if let teamsLastUpdatedAt = dataController.teamsLastUpdatedAt {
                Text("Last Updated: \(teamsLastUpdatedAt.formatted(date: .abbreviated, time: .standard))")
                    .font(.footnote)
                    .padding()
                    .background(Color.primary.colorInvert())
                    .clipShape(Capsule())
                    .shadow(radius: 3)
            }
        }
        .navigationTitle("Teams")
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
            print(error.localizedDescription)
        }
    }

    func updateCache(with downloadedTeams: [Team]) {
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
