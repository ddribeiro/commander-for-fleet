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
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)

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
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Text(host.hardwareSerial)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if dataController.selectedFilter != .recentlyEnrolled {
                        Text(host.hardwareModel)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Enrolled on \(host.lastEnrolledAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundStyle(host.status == "online" ? .green : .red)

                    Text(host.status)
                        .font(.subheadline.smallCaps())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
