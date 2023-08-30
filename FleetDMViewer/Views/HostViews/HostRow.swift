//
//  HostRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct HostRow: View {
    var host: CachedHost
    var body: some View {
        NavigationLink(value: host) {
            HStack {
                Image(systemName: "laptopcomputer")
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(host.wrappedComputerName)
                        .font(.headline)
                        .lineLimit(1)

                    Text(host.wrappedHardwareSerial)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text(host.wrappedHardwareModel)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundColor(host.status == "online" ? .green : .red)

                    Text(host.wrappedStatus)
                        .font(.body.smallCaps())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
