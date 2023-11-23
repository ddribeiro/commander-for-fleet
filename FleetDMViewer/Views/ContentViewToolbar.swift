//
//  ContentViewToolbar.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/21/23.
//

import SwiftUI

struct ContentViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Menu {
            Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                dataController.filterEnabled.toggle()
            }

            Divider()

            Menu("Sort By") {
                Picker("Sort By", selection: $dataController.sortType) {
                    Text("Name").tag(SortType.name)
                    Text("Enrollment Date").tag(SortType.enolledDate)
                    Text("Last Seen").tag(SortType.updatedDate)
                }

                Divider()

                Picker("Sort Order", selection: $dataController.sortOldestFirst) {
                    Text(dataController.sortType == .name ? "Alphabetical" : "Oldest to Newest").tag(true)
                    Text(dataController.sortType == .name ? "Reverse Alphabetical" : "Newest to Oldest").tag(false)
                }
            }

                Picker("Status", selection: $dataController.filterStatus) {
                    Text("All").tag(Status.all)
                    Text("Online").tag(Status.online)
                    Text("Offline").tag(Status.offline)
                    Text("Recently Enrolled").tag(Status.recentlyEnrolled)
                    Text("Missing").tag(Status.missing)
                }
                .disabled(dataController.filterEnabled == false)
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(dataController.filterEnabled ? .fill : .none)
        }
    }
}

#Preview {
    ContentViewToolbar()
}
