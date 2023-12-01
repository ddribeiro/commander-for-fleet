//
//  SoftwareView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftUI

struct AllSoftwareView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<CachedSoftware.ID> = []
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    var displayAsList: Bool {
#if os(iOS)
        return sizeClass == .compact
#else
        return false
#endif
    }

    var body: some View {
        ZStack {
            if displayAsList {
                EmptyView()
            } else {
                AllSoftwareTableView(selection: $selection)
            }
        }
        .navigationTitle("Software")
        .task {
            if let softwareLastUpdatedAt = dataController.softwareLastUpdatedAt {
                guard softwareLastUpdatedAt < .now.addingTimeInterval(-43200) else { return }
            }
            await fetchSoftware()
        }
        .refreshable {
            await fetchSoftware()
        }
        .onAppear {
            dataController.filterText = ""
        }
        .overlay {
            if dataController.softwareForSelectedFilter().isEmpty {
                ContentUnavailableView.search
            }
        }
        .searchable(text: $dataController.filterText)
        .toolbar {
            if !displayAsList {
                toolbarButtons
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if let updatedAt = dataController.softwareLastUpdatedAt {
                    VStack {
                        Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.footnote)
                        Text("^[\(dataController.softwareForSelectedFilter().count) Software Titles](inflection: true)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var toolbarButtons: some View {
        NavigationLink(value: selection.first) {
            Label("View Details", systemImage: "list.bullet.below.rectangle")
        }
        .disabled(selection.isEmpty)
    }

    func fetchSoftware() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            let software = try await networkManager.fetch(.software, attempts: 5)

            await MainActor.run {
                moc.perform {
                    updateCache(with: software)
                }
            }
            dataController.softwareLastUpdatedAt = .now
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

    func updateCache(with downloadedSoftware: [Software]) {
        for downloadedSoftware in downloadedSoftware {
            let cachedSoftware = CachedSoftware(context: moc)

            cachedSoftware.id = Int32(downloadedSoftware.id)
            cachedSoftware.name = downloadedSoftware.name
            cachedSoftware.version = downloadedSoftware.version
            cachedSoftware.bundleIdentifier = downloadedSoftware.bundleIdentifier
            cachedSoftware.source = downloadedSoftware.source
            cachedSoftware.hostCount = Int16(downloadedSoftware.hostsCount ?? 0)

            if let vulnerabilities = downloadedSoftware.vulnerabilities {
                for vulnerability in vulnerabilities {
                    let cachedVulnerability = CachedVulnerability(context: moc)
                    cachedVulnerability.cisaKnownExploit = vulnerability.cisaKnownExploit ?? false
                    cachedVulnerability.cve = vulnerability.cve
                    cachedVulnerability.cveDescription = vulnerability.cveDescription
                    cachedVulnerability.cvePublished = vulnerability.cvePublished
                    cachedVulnerability.cvssScore = vulnerability.cvssScore ?? 0
                    cachedVulnerability.detailsLink = vulnerability.detailsLink
                    cachedVulnerability.epssProbability = vulnerability.epssProbability ?? 0
                    cachedVulnerability.resolvedInVersion = vulnerability.resolvedInVersion

                    cachedSoftware.addToVulnerabilities(cachedVulnerability)
                }
            }
        }

        try? moc.save()
    }
}
