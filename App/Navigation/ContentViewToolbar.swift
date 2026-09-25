//
//  ContentViewToolbar.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/21/23.
//

import SwiftUI

struct ContentViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Menu {
            Menu("Sort By") {
                Picker("Sort By", selection: $dataController.sortType) {
                    Text("Name").tag(SortType.name)
                    Text("Enrollment Date").tag(SortType.enrolledDate)
                    Text("Last Seen").tag(SortType.updatedDate)
                }

                Divider()

                Picker("Sort Order", selection: $dataController.sortOldestFirst) {
                    Text(dataController.sortType == .name ? "Alphabetical" : "Oldest to Newest").tag(true)
                    Text(dataController.sortType == .name ? "Reverse Alphabetical" : "Newest to Oldest").tag(false)
                }
            }

                Picker("Status", selection: $dataController.filterStatus) {
                    Text("All").tag(HostStatus.all)
                    Text("Online").tag(HostStatus.online)
                    Text("Offline").tag(HostStatus.offline)
                    Text("Recently Enrolled").tag(HostStatus.recentlyEnrolled)
                    Text("Missing").tag(HostStatus.missing)
                }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(dataController.filterStatus != .all ? .fill : .none)
        }
    }
}

#Preview {
    ContentViewToolbar()
        .environmentObject(DataController(networkManager: NetworkManager(authManager: AuthManager())))
}
