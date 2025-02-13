//
//  HostHardwareDetailsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 9/22/24.
//

import SwiftUI

struct HostHardwareDetailsView: View {
    let host: Host

    var body: some View {
        Section {
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

            LabeledContent("Memory", value: "\(host.memory / 1073741824) GB")

        } header: {
            Label("Device Information", systemImage: "laptopcomputer")
        }

    }
}

#Preview {
    HostHardwareDetailsView(host: .example)
}
