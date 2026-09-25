//
//  UsersTableView.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UsersTableView: View {
    @EnvironmentObject var dataController: DataController

    @State private var sortOrder = [KeyPathComparator(\User.name)]

    @Binding var selection: Set<User.ID>

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name) { user in
                UserRow(user: user)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Role") { user in
                Text((user.globalRole ?? "—").capitalized)
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Email Address", value: \.email) { user in
                Text(user.email)
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Details") { user in
                Menu {
                    NavigationLink(value: user.id) {
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
                ForEach(dataController.usersForSelectedFilter(), id: \.id) { user in
                    TableRow(user)
                }
            }
        }
    }
}
