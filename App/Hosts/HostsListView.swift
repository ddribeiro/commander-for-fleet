//
//  HostsListView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftData
import SwiftUI
import KeychainWrapper

struct HostsListView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.modelContext) var modelContext
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false
    
    @Query var teams: [CachedTeam]
    @Query var hosts: [CachedHost]

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.name, icon: "person.3", team: team)
        }
    }

    var body: some View {
        if dataController.isAuthenticated {
            List(selection: $dataController.selectedHost) {
                ForEach(hosts) { host in
                    HostRow(host: host)
                }
            }
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
    
    init(searchString: String = "", sortOrder: [SortDescriptor<CachedHost>] = [], filter: Filter = .all) {
        _hosts = Query(filter: #Predicate { host in
            if searchString.isEmpty {
                true
            } else {
                host.computerName.localizedStandardContains(searchString)
                || host.hardwareSerial.localizedStandardContains(searchString)
            }
        }, sort: sortOrder)
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
            let cachedHost = CachedHost(
                computerName: downloadedHost.computerName,
                cpuBrand: downloadedHost.cpuBrand,
                diskEncryptionEnabled: downloadedHost.diskEncryptionEnabled ?? false,
                gigsDiskSpaceAvailable: downloadedHost.gigsDiskSpaceAvailable,
                hardwareModel: downloadedHost.hardwareModel,
                hardwareSerial: downloadedHost.hardwareSerial,
                id: downloadedHost.id,
                lastEnrolledAt: downloadedHost.lastEnrolledAt,
                memory: downloadedHost.memory,
                osVersion: downloadedHost.osVersion,
                percentDiskSpaceAvailable: downloadedHost.percentDiskSpaceAvailable,
                platform: downloadedHost.platform,
                primaryIp: downloadedHost.primaryIp,
                primaryMac: downloadedHost.primaryMac,
                publicIp: downloadedHost.publicIp,
                seenTime: downloadedHost.seenTime,
                status: downloadedHost.status,
                teamId: downloadedHost.teamId ?? 0,
                teamName: downloadedHost.teamName ?? "",
                uptime: downloadedHost.uptime,
                uuid: downloadedHost.uuid
            )
            
            modelContext.insert(cachedHost)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
