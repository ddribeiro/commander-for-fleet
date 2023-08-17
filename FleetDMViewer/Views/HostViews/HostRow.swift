//
//  HostRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct HostRow: View {
    @EnvironmentObject var viewModel: ViewModel
    var host: Host
    var body: some View {
        NavigationLink(value: host) {
            HStack {
                Image(systemName: "laptopcomputer")
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(host.computerName)
                        .font(.headline)
                        .lineLimit(1)

                    Text(host.hardwareSerial)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text(host.hardwareModel)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .foregroundColor(host.status == "online" ? .green : .red)

                    Text(host.status)
                        .font(.body.smallCaps())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct HostRow_Previews: PreviewProvider {
    static var previews: some View {
        HostRow(host: .example)
    }
}
