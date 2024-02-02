//
//  ContentViewToolbar.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/21/23.
//

import SwiftUI

struct ContentViewToolbar: View {
    @State var sortOptions: SortOptions

    var body: some View {
        Menu {
            Menu("Sort By") {
                Picker("Sort By", selection: $sortOptions.selectedSortType) {
                    Text("Name").tag(SortOptions.SortType.name)
                    Text("Enrollment Date").tag(SortOptions.SortType.enolledDate)
                    Text("Last Seen").tag(SortOptions.SortType.updatedDate)
                }

                Divider()

                Picker("Sort Order", selection: $sortOptions.selectedSortOrder) {
                    Text(
                        sortOptions.selectedSortType == .name ?
                        "Alphabetical" : "Oldest to Newest"
                    )
                    .tag(SortOrder.forward)

                    Text(
                        sortOptions.selectedSortType == .name ?
                        "Reverse Alphabetical" : "Newest to Oldest"
                    )
                    .tag(SortOrder.reverse)
                }
            }

            Picker("Status", selection: $sortOptions.selectedSortStatus) {
                Text("All").tag(SortOptions.Status.all)
                Text("Online").tag(SortOptions.Status.online)
                Text("Offline").tag(SortOptions.Status.offline)
                Text("Recently Enrolled").tag(SortOptions.Status.recentlyEnrolled)
                Text("Missing").tag(SortOptions.Status.missing)
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(sortOptions.selectedSortStatus != .all ? .fill : .none)
        }
    }
}
