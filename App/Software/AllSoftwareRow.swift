//
//  AllSoftwareRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftUI

struct AllSoftwareRow: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var software: CachedSoftware

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
                Text(software.wrappedName)
                    .font(.headline)
                    .lineLimit(1)

                if sizeClass == .compact {

                    Text("Version: \(software.wrappedVersion)")
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())

                    Text("^[\(software.hostCount) host](inflect: true)")
                        .font(.smallCaps(.body)())
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
            if sizeClass == .compact {
                if software.vulnerabilitiesArray.count != 0 {
                    VStack(alignment: .trailing) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(.red)
                        Text("^[\(software.vulnerabilitiesArray.count) Vulnerability](inflect: true)")
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                            .font(.body.smallCaps())
                    }
                }
            }
        }
    }
}
