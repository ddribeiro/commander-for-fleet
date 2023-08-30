//
//  ContentView2.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI
import KeychainWrapper

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController

    @State private var isShowingSignInSheet = false
    @State private var selectedHost: Host?
    @FetchRequest(sortDescriptors: [SortDescriptor(\.computerName)]) var hosts: FetchedResults<CachedHost>

    var body: some View {
        if dataController.isAuthenticated {

            List(selection: $dataController.selectedHost) {
                ForEach(dataController.hostsForSelectedFilter()) { host in
                    HostRow(host: host)
                }
            }
            .refreshable {
                await fetchHosts()
            }
            .task {
                guard hosts.isEmpty else { return }
                await fetchHosts()
            }
            .navigationTitle(dataController.selectedFilter?.team?.wrappedName ?? "Hosts")
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
            let hosts = try await networkManager.fetch(.hosts)

            await MainActor.run {
                updateCache(with: hosts)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateCache(with downloadedHosts: [Host]) {
        for downloadedHost in downloadedHosts {
            let cachedHost = CachedHost(context: moc)

            cachedHost.id = Int16(downloadedHost.id)
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
        }

        try? moc.save()
    }

//    var filteredHosts: [Host] {
//        hosts.filter { host in
//            Int16(host.teamId ?? 0) == dataController.selectedTeam?.id
//        }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
