//
//  HostStorageDetailsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 9/22/24.
//

import SwiftUI

struct HostStorageDetailsView: View {
    var host: Host

    var body: some View {
        Section {
            let gigsSpaceConsumed = (host.gigsTotalDiskSpace - host.gigsDiskSpaceAvailable)

            Gauge(value: gigsSpaceConsumed, in: 0...host.gigsTotalDiskSpace) {
                Text("Storage")
            } currentValueLabel: {
                Text("\(Int(gigsSpaceConsumed)) GB of \(Int(host.gigsTotalDiskSpace)) GB used")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HostStorageDetailsView(host: .example)
}
