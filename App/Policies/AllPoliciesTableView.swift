//
//  AllPoliciesTable.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftUI

struct AllPoliciesTableView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @Binding var selection: Set<CachedPolicy.ID>
    @Binding var searchText: String

    @State private var sortOrder = [KeyPathComparator(\CachedPolicy.id, order: .reverse)]

    var searchResults: [CachedPolicy] {
        if searchText.isEmpty {
            return dataController.policiesforSelectedFilter()
        } else {
            return dataController.policiesforSelectedFilter().filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.id) { policy in
                AllPoliciesRow(policy: policy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Passing", value: \.passingHostCount) { policy in
                Text("^[\(policy.passingHostCount) host](inflect: true)")
                    .frame(alignment: .trailing)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }
            .width(100)

            TableColumn("Failing", value: \.failingHostCount) { policy in
                Text("^[\(policy.failingHostCount) host](inflect: true)")
                    .frame(alignment: .trailing)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }
            .width(100)

            TableColumn("Details") { policy in
                Menu {
                    NavigationLink(value: policy) {
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
                ForEach(searchResults, id: \.id) { policy in
                    TableRow(policy)
                }
            }
        }
    }
}
