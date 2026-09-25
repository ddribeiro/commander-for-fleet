//
//  HostHardwareDetailsView.swift
//  Commander
//
//  Created by Dale Ribeiro on 9/22/24.
//

import SwiftUI

struct HostHardwareDetailsView: View {
    let host: Host

    var body: some View {
        Group {
            LabeledContent("Device Name", value: host.computerName)

            LabeledContent {
                Text(host.hardwareSerial)
                    .monospaced()
            } label: {
                Text("Serial Number")
            }

            LabeledContent("Model", value: host.hardwareModel)

            LabeledContent("OS Version", value: host.osVersion)

            LabeledContent("Processor", value: host.cpuBrand)
                .multilineTextAlignment(.trailing)

            LabeledContent("Memory") {
                Text(ByteCountFormatter.string(fromByteCount: Int64(host.memory), countStyle: .memory))
            }
        }
    }
}

#Preview {
    HostHardwareDetailsView(host: .example)
}
