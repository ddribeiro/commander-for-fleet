//
//  SoftwareDetailView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/7/23.
//

import SwiftUI

struct SoftwareDetailView: View {
    var software: CachedSoftware

    var body: some View {
        Form {
            Section {
                LabeledContent("Name", value: software.name)
                    .multilineTextAlignment(.trailing)

                LabeledContent("Version", value: software.version)

                if let bundleIdentifier = software.bundleIdentifier {
                    LabeledContent("Bundle Identifier", value: bundleIdentifier)
                }
            } header: {
                Label("Software Details", systemImage: "app.badge")
            }

            Section {

                NavigationLink {
                    HostsForSoftwareList(software: software)
                } label: {
                    // swiftlint:disable:next line_length
                    Text("^[View \(software.hostsCount) host](inflect: true) with version \(software.version) of \(software.name)")
                }
            } header: {
                Label("Hosts", systemImage: "laptopcomputer")
            }

            Section {
                if !software.vulnerabilities.isEmpty {
                    ForEach(software.vulnerabilities, id: \.cve) { vulnerability in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vulnerability.cve)
                                if vulnerability.cvssScore != 0 {
                                    Text("CVSS Score: \(vulnerability.cvssScore ?? 0)")
                                        .foregroundStyle(.secondary)
                                        .font(.body.smallCaps())
                                }

                                if vulnerability.epssProbability != nil {
                                    Text("EPSS Probability: \(vulnerability.epssProbability!.formatted(.percent))")
                                        .foregroundStyle(.secondary)
                                        .font(.body.smallCaps())
                                }
                            }

                            Spacer()

                            HStack {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .foregroundStyle(.red)
                                Text("Known Exploit")
                                    .font(.body.smallCaps())
                            }
                            .opacity(vulnerability.cisaKnownExploit ?? false ? 1 : 0)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Vulnerabilities",
                        systemImage: "checkmark.seal.fill",
                        description: Text(
                            "There are no reported vulnerabilities for this version of the software."
                        )
                    )

                }
            } header: {
                Label("Vulnerabilities", systemImage: "dot.scope.laptopcomputer")
            }
        }
        .navigationTitle(software.name)
    }
}
