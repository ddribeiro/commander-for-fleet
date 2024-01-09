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
    @Binding var searchText: String

    var searchResults: [CachedUser] {
        if searchText.isEmpty {
            return dataController.usersForSelectedFilter()
        } else {
            return dataController.usersForSelectedFilter().filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.id) { user in
                UserRow(user: user)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Global Role", value: \.globalRole) { user in
                Text(user.globalRole?.capitalized ?? "")
#if os(macOS)
                    .frame(maxWidth: .infinity, alignment: . trailing)
                    .foregroundStyle(.secondary)
#endif
            }

            TableColumn("Email Address", value: \.email) { user in
                Text(user.email)
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
                ForEach(searchResults, id: \.id) { user in
                    TableRow(user)
                }
            }
        }
    }
}
