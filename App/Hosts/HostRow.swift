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
                switch host.platform {
                case "ios":
                    Image(systemName: "iphone")
                        .font(.title)
                default:
                    Image(systemName: "laptopcomputer")
                        .font(.title)
                }

                VStack(alignment: .leading) {
                    Text(host.wrappedComputerName != "" ? host.wrappedComputerName : host.wrappedHardwareSerial)
                        .font(.headline)
                        .lineLimit(1)

                    if dataController.selectedFilter == .all || dataController.selectedFilter == .recentlyEnrolled {
                        Text(host.wrappedTeamName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Text(host.wrappedHardwareSerial)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if dataController.selectedFilter != .recentlyEnrolled {
                        Text(host.wrappedHardwareModel)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Enrolled on \(host.wrappedLastEnrolledAt.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundStyle(host.status == "online" ? .green : .red)

                    Text(host.wrappedStatus)
                        .font(.body.smallCaps())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
