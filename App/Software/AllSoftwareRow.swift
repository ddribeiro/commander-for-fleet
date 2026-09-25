//
//  AllSoftwareRow.swift
//  Commander
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftUI

struct AllSoftwareRow: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var software: Software

    var body: some View {
        HStack {
            Image(systemName: "app.badge")
                .imageScale(.large)
#if os(iOS)
                .frame(width: 40, height: 40)
#else
                .frame(width: 20, height: 20)
#endif
            VStack(alignment: .leading) {
                Text(software.name)
                    .font(.headline)
                    .lineLimit(1)

                if sizeClass == .compact {

                    Text("Version: \(software.version)")
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())

                    if let hostCount = software.hostsCount {
                        Text("^[\(hostCount) Host](inflect: true)")
                            .font(.smallCaps(.body)())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
            if sizeClass == .compact {
                if let vulnerabilityCount = software.vulnerabilities?.count, vulnerabilityCount != 0 {
                    VStack(alignment: .trailing) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(.red)
                        Text("^[\(vulnerabilityCount) Vulnerability](inflect: true)")
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                            .font(.body.smallCaps())
                    }
                }
            }
        }
    }
}
