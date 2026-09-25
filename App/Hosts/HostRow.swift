//
//  HostRow.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct HostRow: View {
    @EnvironmentObject var dataController: DataController

    var host: Host

    var body: some View {
        HStack(spacing: 16) {
            // Device icon with SF Symbol
            Image(systemName: host.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            // Main content
            VStack(alignment: .leading, spacing: 2) {
                // Host name - primary text
                Text(host.computerName.isEmpty ? host.hardwareSerial : host.computerName)
                    .font(.headline)
                    .lineLimit(1)
                    .accessibilityIdentifier("host-name-\(host.id)")

                // Team name (when showing all or recently enrolled)
                if (dataController.selectedFilter == .all || dataController.selectedFilter == .recentlyEnrolled),
                   let teamName = host.teamName, !teamName.isEmpty {
                    Text(teamName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Serial number
                if !host.hardwareSerial.isEmpty {
                    Text(host.hardwareSerial)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Additional context based on filter
                if dataController.selectedFilter != .recentlyEnrolled {
                    if !host.hardwareModel.isEmpty {
                        Text(host.hardwareModel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                } else if host.lastEnrolledAt > .distantPast {
                    Text("Enrolled \(host.lastEnrolledAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Status indicator
            statusIndicator
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var statusIndicator: some View {
        HStack(spacing: 4) {
            // Status dot
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)

            // Status text
            Text(host.status.capitalized)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(statusColor.opacity(0.15))
        )
        .foregroundStyle(statusColor)
    }

    private var statusColor: Color {
        switch host.status.lowercased() {
        case "online":
            return .green
        case "offline":
            return .red
        default:
            return .secondary
        }
    }
}

#Preview {
    List {
        HostRow(host: .example)
    }
    .listStyle(.insetGrouped)
    .environmentObject(DataController(networkManager: NetworkManager(authManager: AuthManager())))
}
