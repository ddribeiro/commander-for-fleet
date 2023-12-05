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

    @State private var sortOrder = [KeyPathComparator(\CachedPolicy.id, order: .reverse)]

    @Binding var selection: Set<CachedPolicy.ID>
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
        } rows: {
            Section {
                ForEach(dataController.policiesforSelectedFilter(), id: \.id) { policy in
                    TableRow(policy)
                }
            }
        }
    }
}
