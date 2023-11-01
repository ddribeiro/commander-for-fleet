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
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false
    @FetchRequest(sortDescriptors: [SortDescriptor(\.computerName)]) var hosts: FetchedResults<CachedHost>

    var body: some View {
        if dataController.isAuthenticated {
            List(selection: $dataController.selectedHost) {
                ForEach(dataController.hostsForSelectedFilter()) { host in
                    HostRow(host: host)
                }
            }
            .searchable(
                text: $dataController.filterText,
                tokens: $dataController.filterTokens,
                suggestedTokens: $dataController.allTokens
            ) { token in
                Text(token.name)
            }
            .overlay {
                if dataController.hostsForSelectedFilter().isEmpty {
                    ContentUnavailableView.search
                }
            }
            .refreshable {
                await fetchHosts()
            }
            .task {
                if let hostsLastUpdatedAt = dataController.hostsLastUpdatedAt {
                    guard hostsLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
                }

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
        guard dataController.activeEnvironment != nil else { return }

        do {
            let hosts = try await networkManager.fetch(.hosts)

            await MainActor.run {
                updateCache(with: hosts)
                dataController.hostsLastUpdatedAt = .now
            }
        } catch {
            print(error.localizedDescription)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
