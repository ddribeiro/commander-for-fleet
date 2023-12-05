//
//  HostsTable.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct HostsTable: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false
    @State private var sortOrder = [KeyPathComparator(\CachedHost.wrappedComputerName, order: .reverse)]

    @Binding var selection: Set<CachedHost.ID>

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.id) { host in
                NewHostRow(host: host)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Serial Number", value: \.wrappedHardwareSerial) { host in
                Text(host.wrappedHardwareSerial)
                    .monospaced()
            }

            TableColumn("Model", value: \.wrappedHardwareModel) { host in
                Text(host.wrappedHardwareModel)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Team", value: \.wrappedTeamName) { host in
                Text(host.wrappedTeamName)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Last Seen", value: \.wrappedSeenTime) { host in
                Text(host.formattedDate)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Status", value: \.wrappedStatus) { host in
                HStack {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundColor(host.wrappedStatus == "online" ? .green : .red)

                    Text(host.wrappedStatus.capitalized)
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
                ForEach(dataController.hostsForSelectedFilter(), id: \.id) { host in
                    TableRow(host)
                }
            }
        }
    }
}
