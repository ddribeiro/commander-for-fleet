//
//  SoftwareDetailView.swift
//  Commander
//
//  Created by Dale Ribeiro on 12/7/23.
//

import SwiftUI

struct SoftwareDetailView: View {
    var software: Software

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
                if (software.hostsCount ?? 0) != 0 {
                    NavigationLink {
                        HostsForSoftwareList(software: software)
                    } label: {
                        Text("^[View \(software.hostsCount ?? 0) hosts](inflect: true) with version \(software.version) of \(software.name)")
                    }
                } else {
                    ContentUnavailableView(
                        "No Hosts",
                        systemImage: "laptopcomputer",
                        description: Text("There are no hosts with this software installed."
                                         )
                    )
                }
            } header: {
                Label("Hosts", systemImage: "laptopcomputer")
            }

            Section {
                if let vulnerabilities = software.vulnerabilities, !vulnerabilities.isEmpty {
                    ForEach(vulnerabilities, id: \.cve) { vulnerability in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vulnerability.cve)
                                if let cvssScore = vulnerability.cvssScore, cvssScore != 0 {
                                    Text("CVSS Score: \(cvssScore)")
                                        .foregroundStyle(.secondary)
                                        .font(.body.smallCaps())
                                }

                                if let epssProbability = vulnerability.epssProbability, epssProbability != 0 {
                                    Text("EPSS Probability: \(epssProbability.formatted(.percent))")
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
                            .opacity(vulnerability.cisaKnownExploit == true ? 1 : 0)
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
