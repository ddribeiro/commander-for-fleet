//
//  SoftwareDetailView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/7/23.
//

import SwiftUI

struct SoftwareDetailView: View {
    @Environment(\.managedObjectContext) var moc

    var software: CachedSoftware

    var body: some View {
        Form {
            Section {
                LabeledContent("Name", value: software.wrappedName)
                    .multilineTextAlignment(.trailing)

                LabeledContent("Version", value: software.wrappedVersion)

                if let bundleIdentifier = software.bundleIdentifier {
                    LabeledContent("Bundle Identifier", value: bundleIdentifier)
                }
            } header: {
                Label("Software Details", systemImage: "app.badge")
            }

            Section {
                if software.hostCount != 0 {
                    NavigationLink {
                        HostsForSoftwareList(software: software)
                    } label: {
                        Text("^[View \(software.hostCount) hosts](inflect: true) with version \(software.wrappedVersion) of \(software.wrappedName)")
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
                if !software.vulnerabilitiesArray.isEmpty {
                    ForEach(software.vulnerabilitiesArray, id: \.cve) { vulnerability in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vulnerability.wrappedCve)
                                if vulnerability.cvssScore != 0 {
                                    Text("CVSS Score: \(vulnerability.cvssScore)")
                                        .foregroundStyle(.secondary)
                                        .font(.body.smallCaps())
                                }

                                if vulnerability.epssProbability != 0 {
                                    Text("EPSS Probability: \(vulnerability.epssProbability.formatted(.percent))")
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
                            .opacity(vulnerability.cisaKnownExploit ? 1 : 0)
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
        .navigationTitle(software.wrappedName)
    }
}
