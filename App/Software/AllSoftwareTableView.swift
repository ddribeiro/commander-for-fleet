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
    @Binding var searchText: String
    @Binding var isShowingVulnerableSoftware: Bool

    var searchResults: [CachedSoftware] {
        if searchText.isEmpty && !isShowingVulnerableSoftware {
            return dataController.softwareForSelectedFilter().sorted {
                $0.wrappedName < $1.wrappedName
            }
        } else if searchText.isEmpty && isShowingVulnerableSoftware {
            return vulnerableSoftware.sorted {
                $0.wrappedName < $1.wrappedName
            }
        } else if isShowingVulnerableSoftware {
                return vulnerableSoftware.filter({ $0.wrappedName.localizedCaseInsensitiveContains(searchText) })
            } else {
            return dataController.softwareForSelectedFilter().filter {
                $0.wrappedName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var vulnerableSoftware: [CachedSoftware] {
        dataController.softwareForSelectedFilter().filter {
            !$0.vulnerabilitiesArray.isEmpty
        }
    }

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.id) { software in
                AllSoftwareRow(software: software)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

            }
            .width(400)

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
                HStack {

                        Image(systemName: "exclamationmark.shield.fill")
                            .opacity(software.vulnerabilitiesArray.count != 0 ? 1 : 0)
                            .imageScale(.large)
                            .foregroundStyle(.red)

                    Text("\(software.vulnerabilitiesArray.count)")
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
                ForEach(searchResults) { software in
                    TableRow(software)
                }
            }
        }
        .id(UUID())
    }
}
