//
//  HostRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct HostRow: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.horizontalSizeClass) var sizeClass
    var host: CachedHost

    var body: some View {
        HStack {
            Image(systemName: host.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .accessibility(hidden: true)

            if sizeClass == .compact {
                VStack(alignment: .leading) {
                    Text(host.wrappedComputerName != "" ? host.wrappedComputerName : host.wrappedHardwareSerial)
                        .font(.headline)

                    if dataController.selectedFilter == .all || dataController.selectedFilter == .recentlyEnrolled {
                        Text(host.wrappedTeamName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Text(host.wrappedHardwareSerial)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if dataController.selectedFilter != .recentlyEnrolled {
                        Text(host.wrappedHardwareModel)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Enrolled on \(host.wrappedLastEnrolledAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundStyle(host.status == "online" ? .green : .red)

                    Text(host.wrappedStatus)
                        .font(.subheadline.smallCaps())
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(host.wrappedComputerName != "" ? host.wrappedComputerName : host.wrappedHardwareSerial)
                    .font(.headline)
                    .lineLimit(1)
            }
        }
    }
}
