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
                SoftwareListView(
                    sort: sortOrder,
                    searchString: searchText,
//                    filter: Filter.all,
                    isShowingVulnerableSoftware: isShowingVulnerableSoftware
                    )
            } else {
                AllSoftwareTableView(
                    sort: sortOrder,
                    searchString: searchText,
                    isShowingVulnerableSoftware: isShowingVulnerableSoftware,
                    selection: $selection
                )
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
                                await CachedSoftware.refresh(
                                    forTeam: team.id,
                                    modelContext: modelContext,
                                    dataController: dataController
                                )
                            }
                        }
                    } else {
                        Task {
                            await CachedSoftware.refresh(
                                modelContext: modelContext,
                                dataController: dataController
                            )
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
                                await CachedSoftware.refresh(forTeam: team.id, modelContext: modelContext, dataController: dataController)
                            }
                        }
                    } else {
                        Task {
                            await CachedSoftware.refresh(modelContext: modelContext, dataController: dataController)
                        }
                    }
                }
            }
        }
        .overlay {
            if software.isEmpty {
                ContentUnavailableView.search
            }
        }
        .searchable(text: $searchText)
                .toolbar {
                    if !displayAsList {
                        toolbarButtons
                    }
                }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingVulnerableSoftware.toggle()
                    print(isShowingVulnerableSoftware)
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
}
