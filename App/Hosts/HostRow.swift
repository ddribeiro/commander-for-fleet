//
//  HostRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct HostRow: View {
    @EnvironmentObject var dataController: DataController
    var host: CachedHost
    var body: some View {
        NavigationLink(value: host.id) {
            HStack {
                Image(systemName: "laptopcomputer")
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(host.computerName)
                        .font(.headline)
                        .lineLimit(1)

                    if !host.teamName.isEmpty
                        && (
                            dataController.selectedFilter == .all
                            || dataController.selectedFilter == .recentlyEnrolled
                        ) {
                        Text(host.teamName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Text(host.hardwareSerial)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if dataController.selectedFilter != .recentlyEnrolled {
                        Text(host.hardwareModel)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Enrolled on \(host.lastEnrolledAt.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundStyle(host.status == "online" ? .green : .red)

                    Text(host.status)
                        .font(.body.smallCaps())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
