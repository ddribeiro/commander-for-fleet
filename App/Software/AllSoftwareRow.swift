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
                Text(software.name)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(software.id)")

                if sizeClass == .compact {
                    Text("Version: \(software.version)")
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())

                    Text("^[\(software.hostsCount) host](inflect: true)")
                        .font(.smallCaps(.body)())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
