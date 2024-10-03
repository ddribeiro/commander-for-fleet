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
            switch host.platform {
            case "ios":
                Image(systemName: "iphone")
                    .font(.title)
                    .padding(2)
#if os(iOS)
                    .frame(width: 40, height: 40)
#else
                    .frame(width: 20, height: 20)
#endif
            case "ipados":
                Image(systemName: "ipad")
                    .font(.title)
                    .padding(2)
#if os(iOS)
                    .frame(width: 40, height: 40)
#else
                    .frame(width: 20, height: 20)
#endif
            default:
                Image(systemName: "laptopcomputer")
                    .font(.title)
                    .padding(2)
#if os(iOS)
                    .frame(width: 40, height: 40)
#else
                    .frame(width: 20, height: 20)
#endif
            }
            if sizeClass == .compact {
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
            } else {
                Text(host.wrappedComputerName != "" ? host.wrappedComputerName : host.wrappedHardwareSerial)
                    .font(.headline)
                    .lineLimit(1)
            }
        }
    }
}
