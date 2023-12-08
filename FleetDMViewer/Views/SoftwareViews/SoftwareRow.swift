//
//  SoftwareRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/21/23.
//

import SwiftUI

struct SoftwareRow: View {
    var software: Software

    var body: some View {
            HStack {
                Image(systemName: "app.badge")
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(software.name)
                        .font(.headline)
                        .lineLimit(1)

                    Text("Version: \(software.version)")
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())
                }

                Spacer()

                if let vulnerabilities = software.vulnerabilities {
                    VStack(alignment: .trailing) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(.red)
                            Text("^[\(vulnerabilities.count) Vulnerability](inflect: true)")
                            .foregroundStyle(.secondary)
                            .font(.body.smallCaps())

                    }
                }
            }
    }
}

struct SoftwareRow_Previews: PreviewProvider {
    static var previews: some View {
        SoftwareRow(software: .example)
    }
}
