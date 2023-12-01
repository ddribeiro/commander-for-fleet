//
//  SotwareDetailView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/21/23.
//

import SwiftUI

struct SoftwareDetailView: View {
    var software: Software
    var body: some View {
        Form {
            Section {
                LabeledContent("Name", value: software.name ?? "")
                    .multilineTextAlignment(.trailing)

                LabeledContent("Version", value: software.version ?? "")

                if let bundleIdentifier = software.bundleIdentifier {
                    LabeledContent("Bundle Identifier", value: bundleIdentifier)
                }

                if let installedAt = software.installedPaths {
                    LabeledContent("Installation Location") {
                        ForEach(installedAt, id: \.self) { path in
                            Text(path)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .multilineTextAlignment(.trailing)
                }

                if let lastOpenedDate = software.lastOpenedAt {
                    LabeledContent("Last Opened", value: lastOpenedDate.formatted(date: .abbreviated, time: .complete))
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Label("Software Details", systemImage: "app.badge")
            }
            Section {
                if let vulnerabilities = software.vulnerabilities {
                    ForEach(vulnerabilities, id: \.cve) { vulnerability in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vulnerability.cve)
                                if let cvssScore = vulnerability.cvssScore {
                                    Text("CVSS Score: \(cvssScore)")
                                        .foregroundStyle(.secondary)
                                        .font(.body.smallCaps())
                                }

//                                Text("EPSS Probability: \(vulnerability.epssProbability?.formatted(.percent))")
//                                    .foregroundStyle(.secondary)
//                                    .font(.body.smallCaps())
                            }
                            Spacer()
                            VStack {
                                Image(systemName: "exclamationmark.shield.fill")

                                    .foregroundColor(.red)
                                Text("Known Exploit")
                                    .font(.body.smallCaps())
                            }
                            .opacity(vulnerability.cisaKnownExploit ?? false ? 1 : 0)
                        }

                    }
                } else {
                    Text("No Known Vulnerabilities")
                }
            } header: {
                Label("Vulnerabilities", systemImage: "exclamationmark.shield")
            }
        }
        .navigationTitle(software.name)
    }
}

struct SoftwareDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SoftwareDetailView(software: .example)
    }
}
