//
//  AllSoftwareTableView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftUI

struct AllSoftwareTableView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var sortOrder = [KeyPathComparator(\CachedSoftware.id, order: .reverse)]

    @Binding var selection: Set<CachedSoftware.ID>

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {

            TableColumn("Name", value: \.id) { software in
                AllSoftwareRow(software: software)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Version", value: \.wrappedVersion) { software in
                Text(software.wrappedVersion)
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: . trailing)
                    .foregroundStyle(.secondary)
#endif
                    .monospacedDigit()
            }

            TableColumn("Source", value: \.wrappedSource) { software in
                Text(software.wrappedSource)
            }

            TableColumn("Hosts", value: \.hostCount) { software in
                Text("\(software.hostCount)")
                    .monospacedDigit()
            }

            TableColumn("Vulnerabilties", value: \.vulnerabilitiesArray.count) { software in
                Text("\(software.vulnerabilitiesArray.count)")
                    .monospacedDigit()
            }

            TableColumn("Details") { software in
                Menu {
                    NavigationLink(value: software.id) {
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
                ForEach(dataController.softwareForSelectedFilter(), id: \.id) { software in
                    TableRow(software)
                }
            }
        }
    }
}
