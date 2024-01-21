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

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var sortOrder = [KeyPathComparator(\CachedSoftware.id, order: .reverse)]

    @Binding var selection: Set<CachedSoftware.ID>
    @State private var isShowingVulnerableSoftware: Bool

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
//                return vulnerableSoftware.filter({ $0.name.localizedCaseInsensitiveContains(searchText) })
//            } else {
//            return dataController.softwareForSelectedFilter().filter {
//                $0.name.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }

    var vulnerableSoftware: [CachedSoftware] {
        software.filter {
            !$0.vulnerabilities.isEmpty
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

            TableColumn("Hosts", value: \.hostCount) { software in
                Text("\(software.hostCount)")
                    .monospacedDigit()
            }

            TableColumn("Vulnerabilties", value: \.vulnerabilities.count) { software in
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
                ForEach(software) { software in
                    TableRow(software)
                }
            }
        }
        .id(UUID())
    }

    init(sort: [SortDescriptor<CachedSoftware>], searchString: String, filter: Filter, isShowingVulnerableSoftware: Bool) {
        _software = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true
            } else {
                return $0.name.localizedStandardContains(searchString)
            }
        }, sort: sort)

        _selection = .constant([])
        _sortOrder = State(initialValue: [KeyPathComparator(\CachedSoftware.name)])
        _isShowingVulnerableSoftware = State(initialValue: isShowingVulnerableSoftware)
    }
}
