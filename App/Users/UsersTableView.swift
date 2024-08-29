//
//  UsersTableView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftData
import SwiftUI

struct UsersTableView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var sortOrder = [KeyPathComparator(\CachedUser.name, order: .reverse)]

    @Binding var selection: Set<CachedUser.ID>

    @Query var users: [CachedUser]

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.id) { user in
                UserRow(user: user)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            TableColumn("Global Role") { user in
                if let globalRole = user.globalRole {
                    Text(globalRole.capitalized)
                }
#if os(macOS)
//                    .frame(maxWidth: .infinity, alignment: . trailing)
//                    .foregroundStyle(.secondary)
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
                ForEach(users, id: \.id) { user in
                    TableRow(user)
                }
            }
        }
    }

    init(
        searchText: String,
        filter: Filter,
        sortOptions: SortOptions,
        selection: Binding<Set<CachedUser.ID>>
    ) {
        let predicate = CachedUser.predicate(searchText: searchText, filter: filter, sortOptions: sortOptions)

        _users = Query(filter: predicate)
        _selection = selection
    }
}
