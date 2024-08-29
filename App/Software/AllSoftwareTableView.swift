//
//  AllSoftwareTableView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftData
import SwiftUI

struct AllSoftwareTableView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var sortOrder = [KeyPathComparator(\CachedSoftware.name, order: .forward)]

    @Binding var selection: Set<CachedSoftware.ID>
    @State private var isShowingVulnerableSoftware: Bool

    @Query var software: [CachedSoftware]

    var sortedOrders: [CachedSoftware] {
        software.sorted(using: sortOrder)
    }

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name) { software in
                AllSoftwareRow(software: software)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

            }
            .width(400)

            TableColumn("Version", value: \.version) { software in
                Text(software.version)
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: . trailing)
                    .foregroundStyle(.secondary)
#endif
                    .monospacedDigit()
            }

            TableColumn("Source", value: \.source) { software in
                Text(software.source)
            }

            TableColumn("Hosts", value: \.hostsCount) { software in
                Text("\(software.hostsCount)")
                    .monospacedDigit()
            }

            TableColumn("Vulnerabilities", value: \.vulnerabilities.count) { software in
                HStack {
                    Image(systemName: "exclamationmark.shield.fill")
                        .opacity(software.vulnerabilities.count != 0 ? 1 : 0)
                        .imageScale(.large)
                        .foregroundStyle(.red)

                    Text("\(software.vulnerabilities.count)")
                        .monospacedDigit()
                }
            }

            TableColumn("Details") { software in
                Menu {
                    NavigationLink(value: software) {
                        Label("View Details", systemImage: "list.bullet.below.rectangle")
                    }
                } label: {
                    Label("Details", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .foregroundColor(.secondary)
            }
            .width(60)
        } rows: {
            Section {
                ForEach(sortedOrders, id: \.id) { software in
                    TableRow(software)
                }
            }
        }
        .toolbar {
            #if os(iOS)
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
            #endif
        }
        .overlay {
            if software.isEmpty {
                ContentUnavailableView.search
            }
        }
    }

    init(
        sort: [SortDescriptor<CachedSoftware>],
        searchString: String,
        isShowingVulnerableSoftware: Bool,
        selection: Binding<Set<CachedSoftware.ID>>
    ) {
        let predicate = CachedSoftware.predicate(
            searchText: searchString,
            isShowingVulnerableSoftware: isShowingVulnerableSoftware
        )
        _software = Query(filter: predicate, sort: sort)
        _isShowingVulnerableSoftware = State(initialValue: isShowingVulnerableSoftware)
        _selection = selection
    }
}
