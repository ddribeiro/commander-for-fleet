//
//  AllPoliciesTableView.swift
//  Commander
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftUI

struct AllPoliciesTableView: View {
    @EnvironmentObject var dataController: DataController

    @State private var sortOrder = [KeyPathComparator(\Policy.name)]

    @Binding var selection: Set<Policy.ID>

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name) { policy in
                AllPoliciesRow(policy: policy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Passing") { policy in
                Text(policy.passingHostCount.map(String.init) ?? "—")
                    .frame(maxWidth: .infinity, alignment: .trailing)
#if os(macOS)
                    .foregroundStyle(.secondary)
#endif
            }
            .width(100)

            TableColumn("Failing") { policy in
                Text(policy.failingHostCount.map(String.init) ?? "—")
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
                ForEach(dataController.policiesForSelectedFilter(), id: \.id) { policy in
                    TableRow(policy)
                }
            }
        }
    }
}
