//
//  CommandRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/29/23.
//

import SwiftUI

struct HostCommandRow: View {
    var command: CachedCommandResponse
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(command.wrappedRequestType)
                    .font(.headline)
                Text("\(command.wrappedUpdatedAt.formatted(date: .numeric, time: .shortened))")
                    .foregroundStyle(.secondary)

            }

            Spacer()

            VStack(alignment: .trailing) {
                switch command.status {
                case "Acknowledged":
                    Image(systemName: "checkmark.icloud.fill")
                        .foregroundColor(.green)
                    Text(command.wrappedStatus)
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())

                case "Pending":
                    Image(systemName: "clock.badge.questionmark.fill")
                        .foregroundColor(.secondary)

                    Text(command.wrappedStatus)
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())

                default:
                    Image(systemName: "xmark.icloud.fill")
                        .foregroundColor(.red)
                    Text(command.wrappedStatus)
                        .foregroundColor(.secondary)
                        .font(.body.smallCaps())
                }
            }
        }
    }
}
