//
//  ContentView2.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI
import KeychainWrapper

struct ContentView: View {
    @EnvironmentObject var dataController: DataController

    @State private var isShowingSignInSheet = false
    @State private var hosts = [Host]()
    @State private var selectedHost: Host?

    var body: some View {
        if dataController.isAuthenticated {

            List(selection: $dataController.selectedHost) {
                ForEach(dataController.selectedTeam != nil ? filteredHosts : hosts) { host in
                    HostRow(host: host)
                }
            }
            .refreshable {
                await fetchHosts()
            }
            .task {
                await fetchHosts()
            }
            .navigationTitle(dataController.selectedTeam?.name ?? "Hosts")
        } else {
            NoHostView()
                .sheet(isPresented: $isShowingSignInSheet) {
                    LoginView()
                }
                .onAppear {
                    isShowingSignInSheet = true
                }
        }
    }

    func fetchHosts() async {
        guard let serverURL = KeychainWrapper.default.string(forKey: "serverURL") else {
            print("Could not get server URL")
            return
        }

        let environment = AppEnvironment(baseURL: URL(string: "\(serverURL)")!)

        let networkManager = NetworkManager(environment: environment)

        do {
            hosts = try await networkManager.fetch(.hosts)
        } catch {
            print(error.localizedDescription)
        }
    }

    var filteredHosts: [Host] {
        hosts.filter { host in
            host.teamId == dataController.selectedTeam?.id
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
