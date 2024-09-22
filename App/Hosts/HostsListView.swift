//
//  HostsListView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI
import KeychainWrapper

struct HostsListView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false
    @State private var selection: Set<CachedHost.ID> = []

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.wrappedName, icon: "person.3", team: team)
        }
    }

    var body: some View {
        if dataController.isAuthenticated {
            List(selection: $selection) {
                ForEach(dataController.hostsForSelectedFilter()) { host in
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
                print(error)
            case .none:
                print(error)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
