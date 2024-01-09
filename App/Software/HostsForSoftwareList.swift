//
//  HostsForSoftwareList.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/7/23.
//

import SwiftUI

struct HostsForSoftwareList: View {
    @Environment(\.networkManager) var networkManager

    @EnvironmentObject var dataController: DataController

    @State private var searchText = ""

    var software: CachedSoftware
    @State private var hosts = [Host]()

    var body: some View {
        List {
            ForEach(searchResults) { host in
                HStack {
                    Image(systemName: "laptopcomputer")
                        .imageScale(.large)

                    VStack(alignment: .leading) {
                        Text(host.computerName)
                            .font(.headline)
                            .lineLimit(1)

                        Text(host.teamName ?? "")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Text(host.hardwareSerial)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Image(systemName: "circle.fill")
                            .imageScale(.small)
                            .foregroundStyle(host.status == "online" ? .green : .red)

                        Text(host.status)
                            .font(.body.smallCaps())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .task {
            try? await fetchHostsForSoftware()
        }
        .searchable(text: $searchText)
        .navigationTitle("Hosts for \(software.name)")
    }

var searchResults: [Host] {
    if searchText.isEmpty {
        return hosts
    } else {
        return hosts.filter { $0.computerName.localizedCaseInsensitiveContains(searchText) }
    }
}

func fetchHostsForSoftware() async throws {
    guard dataController.activeEnvironment != nil else { return }

    let endpoint = Endpoint.getHostsForSoftware(softwareID: Int(software.id))

    do {
        dataController.loadingState = .loading
        hosts = try await networkManager.fetch(endpoint)
        dataController.loadingState = .loaded
    } catch {
        switch error as? AuthManager.AuthError {
        case .missingCredentials:
            dataController.loadingState = .failed
            if !dataController.showingApiTokenAlert {
                dataController.showingApiTokenAlert = true
                dataController.alertTitle = "API Token Expired"
                dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
            }
        case .missingToken:
            dataController.loadingState = .failed
            print(error.localizedDescription)
        case .none:
            dataController.loadingState = .failed
            print(error.localizedDescription)
        }
    }
}
}
