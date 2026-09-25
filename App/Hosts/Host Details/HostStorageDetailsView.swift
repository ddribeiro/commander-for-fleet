//
//  HostStorageDetailsView.swift
//  Commander
//
//  Created by Dale Ribeiro on 9/22/24.
//

import SwiftUI

struct HostStorageDetailsView: View {
    var host: Host

    var body: some View {
        if host.gigsTotalDiskSpace > 0 {
            let gigsSpaceConsumed = max(
                0,
                min(host.gigsTotalDiskSpace, host.gigsTotalDiskSpace - host.gigsDiskSpaceAvailable)
            )

            VStack(alignment: .leading, spacing: 8) {
                Gauge(value: gigsSpaceConsumed, in: 0...host.gigsTotalDiskSpace) {
                    Text("Storage")
                } currentValueLabel: {
                    Text("\(Int(gigsSpaceConsumed)) GB of \(Int(host.gigsTotalDiskSpace)) GB used")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } minimumValueLabel: {
                    Text("0 GB")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                } maximumValueLabel: {
                    Text("\(Int(host.gigsTotalDiskSpace)) GB")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .tint(.blue)
            }
        } else {
            LabeledContent("Storage") {
                Text("—")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HostStorageDetailsView(host: .example)
}
