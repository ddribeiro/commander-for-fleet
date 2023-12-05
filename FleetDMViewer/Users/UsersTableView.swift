//
//  UsersTableView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UsersTableView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var sortOrder = [KeyPathComparator(\CachedUser.id, order: .reverse)]

    @Binding var selection: Set<CachedUser.ID>

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.id) { user in
                UserRow(user: user)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Global Role", value: \.wrappedGlobalRole) { user in
                Text(user.wrappedGlobalRole.capitalized)
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: . trailing)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Email Address", value: \.wrappedEmail) { user in
                Text(user.wrappedEmail)
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: . trailing)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Details") { user in
                Menu {
                    NavigationLink(value: user) {
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
                ForEach(dataController.usersForSelectedFilter(), id: \.id) { user in
                    TableRow(user)
                }
            }
        }
    }
}
