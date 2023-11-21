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

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ContentViewToolbar()
                }
                ToolbarItem(placement: .bottomBar) {
                    if let updatedAt = dataController.hostsLastUpdatedAt {
                        VStack {
                            Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                            Text("^[\(dataController.hostsForSelectedFilter().count) computers](inflection: true)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .task {
                if let hostsLastUpdatedAt = dataController.hostsLastUpdatedAt {
                    guard hostsLastUpdatedAt < .now.addingTimeInterval(-300) else { return }
                }

                await fetchHosts()
            }
            .navigationTitle(dataController.selectedFilter?.name ?? "Hosts")
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
        } catch let error as HTTPError {
            await dataController.handleHTTPErrors(networkManager: networkManager, error: error)
            await fetchHosts()
        } catch {
            print("Could not fetch hosts: \(error.localizedDescription)")
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
