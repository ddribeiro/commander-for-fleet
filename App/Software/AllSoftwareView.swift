//
//  SoftwareView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftData
import SwiftUI

struct AllSoftwareView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.networkManager) var networkManager
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var selection: Set<CachedSoftware.ID> = []
    @State private var searchText = ""
    @State private var isShowingVulnerableSoftware = false
    @State private var sortOrder = [SortDescriptor(\CachedSoftware.name)]

    @Query var teams: [CachedTeam]
    @Query var users: [CachedUser]
    @Query var software: [CachedSoftware]

    //    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>
    //    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var users: FetchedResults<CachedUser>

//    var searchResults: [CachedSoftware] {
//        if searchText.isEmpty && !isShowingVulnerableSoftware {
//            return dataController.softwareForSelectedFilter().sorted {
//                $0.name < $1.name
//            }
//        } else if searchText.isEmpty && isShowingVulnerableSoftware {
//            return vulnerableSoftware.sorted {
//                $0.name < $1.name
//            }
//        } else if isShowingVulnerableSoftware {
//            return vulnerableSoftware.filter({ $0.name.localizedCaseInsensitiveContains(searchText) })
//        } else {
//            return dataController.softwareForSelectedFilter().filter {
//                $0.name.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }
//    
//    var vulnerableSoftware: [CachedSoftware] {
//        dataController.softwareForSelectedFilter().filter {
//            !$0.vulnerabilities.isEmpty
//        }
//    }

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
                list
            } else {
                AllSoftwareTableView(sort: sortOrder, searchString: searchText, filter: Filter.all, isShowingVulnerableSoftware: false)
            }
        }
        .navigationDestination(for: CachedSoftware.self) { software in
            SoftwareDetailView(software: software)
        }

        .navigationTitle("Software")
        .task {
            if let softwareLastUpdatedAt = dataController.softwareLastUpdatedAt {
                guard softwareLastUpdatedAt < .now.addingTimeInterval(-43200) else { return }
            }

            if let savedUserID = UserDefaults.standard.value(forKey: "loggedInUserID") as? Int16 {
                if let loggedInUser = users.first(where: { $0.id == savedUserID}) {
                    if loggedInUser.globalRole != "admin" {
                        for team in loggedInUser.teams {
                            Task {
                                await fetchSoftwareForTeam(id: Int(team.id))
                            }
                        }
                    } else {
                        Task {
                            await fetchSoftware()
                        }
                    }
                }
            }
        }
        .refreshable {
            if let savedUserID = UserDefaults.standard.value(forKey: "loggedInUserID") as? Int16 {
                if let loggedInUser = users.first(where: { $0.id == savedUserID}) {
                    if loggedInUser.globalRole != "admin" {
                        for team in loggedInUser.teams {
                            Task {
                                await fetchSoftwareForTeam(id: Int(team.id))
                            }
                        }
                    } else {
                        Task {
                            await fetchSoftware()
                        }
                    }
                }
            }
        }
        .onAppear {
            dataController.filterText = ""
        }
        .overlay {
            if software.isEmpty {
                ContentUnavailableView.search
            }
        }
        .searchable(text: $searchText)
        //        .toolbar {
        //            if !displayAsList {
        //                toolbarButtons
        //            }
        //        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingVulnerableSoftware.toggle()
                } label: {
                    Label("Show Vulnerable Software", systemImage: "exclamationmark.shield")
                        .symbolVariant(isShowingVulnerableSoftware ? .fill : .none)
                }
            }

            ToolbarItem(placement: .bottomBar) {
                if dataController.loadingState == .loaded {
                    VStack {
                        if let updatedAt = dataController.softwareLastUpdatedAt {
                            Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                            Text("^[\(software.count) Software Titles](inflection: true)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if dataController.loadingState == .loading {
                    HStack {
                        ProgressView()
                            .padding(.horizontal, 1)
                            .controlSize(.mini)

                        Text("Loading Software")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                }
            }
        }
#endif
    }

    @ViewBuilder
    var toolbarButtons: some View {
        NavigationLink(value: selection.first) {
            Label("View Details", systemImage: "list.bullet.below.rectangle")
        }
        .disabled(selection.isEmpty)
    }

    func fetchSoftwareForTeam(id: Int) async {
        guard dataController.activeEnvironment != nil else { return }
        let endpoint = Endpoint.getSoftwareForTeam(id: id)

        do {
            dataController.loadingState = .loading
            let software = try await networkManager.fetch(endpoint, attempts: 5)

            await MainActor.run {
                updateCache(with: software)
            }
            dataController.softwareLastUpdatedAt = .now
            dataController.loadingState = .loaded
        } catch {
            dataController.loadingState = .failed
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
                print("Thise error")
                print(error.localizedDescription)
            }
        }
    }

    func fetchSoftware() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            dataController.loadingState = .loading
            let software = try await networkManager.fetch(.software, attempts: 5)

            await MainActor.run {
                updateCache(with: software)
            }

            dataController.softwareLastUpdatedAt = .now
            dataController.loadingState = .loaded
        } catch {
            dataController.loadingState = .failed
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

    var list: some View {
        List {
            softwareRows(software)
        }
        .id(UUID())
    }

    func softwareRows(_ software: [CachedSoftware]) -> some View {
        ForEach(software) { software in
            NavigationLink(value: software) {
                AllSoftwareRow(software: software)
            }
        }
    }

    func updateCache(with downloadedSoftware: [Software]) {
        for downloadedSoftware in downloadedSoftware {
            let cachedSoftware = CachedSoftware(
                bundleIdentifier: downloadedSoftware.bundleIdentifier,
                hostCount: downloadedSoftware.hostsCount ?? 0,
                id: downloadedSoftware.id,
                name: downloadedSoftware.name,
                source: downloadedSoftware.source,
                version: downloadedSoftware.version
            )

            if let vulnerabilities = downloadedSoftware.vulnerabilities {
                for vulnerability in vulnerabilities {
                    let cachedVulnerability = CachedVulnerability(
                        cisaKnownExploit: vulnerability.cisaKnownExploit ?? false,
                        cve: vulnerability.cve,
                        cveDescription: vulnerability.cveDescription,
                        cvePublished: vulnerability.cvePublished,
                        cvssScore: vulnerability.cvssScore ?? 0,
                        detailsLink: vulnerability.detailsLink,
                        epssProbability: vulnerability.epssProbability ?? 0,
                        resolvedInVersion: vulnerability.resolvedInVersion
                    )

                    cachedSoftware.vulnerabilities.append(cachedVulnerability)
                }
            }
            modelContext.insert(cachedSoftware)
        }

    }
}
