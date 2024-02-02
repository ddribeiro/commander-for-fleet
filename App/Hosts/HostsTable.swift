//
//  HostsTable.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftData
import SwiftUI

struct HostsTable: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false
    @State private var sortOrder = [KeyPathComparator(\CachedHost.computerName, order: .forward)]

    @Binding var selection: Set<CachedHost.ID>

    @Query var hosts: [CachedHost]

    var sortedHosts: [CachedHost] {
        hosts.sorted(using: sortOrder)
    }

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.computerName) { host in
                NewHostRow(host: host)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }
            .width(200)

            TableColumn("Serial Number", value: \.hardwareSerial) { host in
                Text(host.hardwareSerial)
                    .monospaced()
            }

            TableColumn("Model", value: \.hardwareModel) { host in
                Text(host.hardwareModel)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Team", value: \.teamName) { host in
                Text(host.teamName)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Last Seen", value: \.seenTime) { host in
                Text(host.formattedDate)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Status", value: \.status) { host in
                HStack {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundColor(host.status == "online" ? .green : .red)

                    Text(host.status.capitalized)
                }
            }

            TableColumn("Details") { host in
                Menu {
                    NavigationLink(value: host.id) {
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
                ForEach(sortedHosts) { host in
                    TableRow(host)
                }
            }
        }
    }

    init(
        searchText: String,
        filter: Filter,
        sortOptions: SortOptions,
        selection: Binding<Set<CachedHost.ID>>
    ) {
        let predicate = CachedHost.predicate(searchText: searchText, filter: filter, sortOptions: sortOptions)

        _hosts = Query(filter: predicate)

        _selection = selection
    }
}
