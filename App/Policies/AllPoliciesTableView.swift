//
//  AllPoliciesTable.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftData
import SwiftUI

struct AllPoliciesTableView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.networkManager) var networkManager

    @Binding var selection: Set<CachedPolicy.ID>
    @State private var sortOrder = [KeyPathComparator(\CachedPolicy.name)]

    @Query var policies: [CachedPolicy]

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
                ForEach(policies.sorted(using: sortOrder), id: \.id) { policy in
                    TableRow(policy)
                }
            }
        }
    }

    init(sort: [SortDescriptor<CachedPolicy>], searchString: String, filter: Filter) {
        _policies = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true
            } else {
                return $0.name.localizedStandardContains(searchString)
            }
        }, sort: sort)

        _selection = .constant([])
        _sortOrder = State(initialValue: [KeyPathComparator(\CachedPolicy.name)])

    }
}
