//
//  AllSoftwareTableView.swift
//  Commander
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftUI

struct AllSoftwareTableView: View {
    @EnvironmentObject var dataController: DataController

    @State private var sortOrder = [KeyPathComparator(\Software.name)]

    @Binding var selection: Set<Software.ID>
    @Binding var isShowingVulnerableSoftware: Bool

    var results: [Software] {
        var results = dataController.softwareForSelectedFilter()

        if isShowingVulnerableSoftware {
            results = results.filter { !($0.vulnerabilities ?? []).isEmpty }
        }

        return results
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
                    .monospacedDigit()
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Source") { software in
                Text(software.source)
            }

            TableColumn("Hosts") { software in
                Text(software.hostsCount.map(String.init) ?? "—")
                    .monospacedDigit()
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
#endif
            }

            TableColumn("Versions") { software in
                Text(software.versionsCount.map(String.init) ?? "—")
                    .monospacedDigit()
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
#endif
            }

            TableColumn("Vulnerabilities") { software in
                HStack {
                    Image(systemName: "exclamationmark.shield.fill")
                        .opacity((software.vulnerabilities?.count ?? 0) != 0 ? 1 : 0)
                        .imageScale(.large)
                        .foregroundStyle(.red)

                    Text("\(software.vulnerabilities?.count ?? 0)")
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
#if os(macOS)
                .menuStyle(.borderlessButton)
#endif
                .menuIndicator(.hidden)
                .fixedSize()
                .foregroundColor(.secondary)
            }
            .width(60)
        } rows: {
            Section {
                ForEach(results, id: \.id) { software in
                    TableRow(software)
                }
            }
        }
    }
}
