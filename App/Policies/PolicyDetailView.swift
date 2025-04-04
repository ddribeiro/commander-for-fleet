//
//  PolicyDetailView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/6/23.
//

import SwiftUI

struct PolicyDetailView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    var policy: CachedPolicy

    @State private var passingHosts = [Host]()
    @State private var failingHosts = [Host]()

    var body: some View {
        Form {
            Section {
                Text(policy.wrappedPolicyDescription)
                    .foregroundStyle(.secondary)
            } header: {
                Label("Description", systemImage: "info.circle")
            }

            Section {
                Text(policy.wrappedQuery)
                    .monospaced()
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Label("Query", systemImage: "rectangle.and.text.magnifyingglass")
            }

            Section {
                if !passingHosts.isEmpty {
                    ForEach(passingHosts) { host in
                        HStack {
                            Image(systemName: "laptopcomputer")
                                .imageScale(.large)

                            VStack(alignment: .leading) {
                                Text(host.computerName)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(host.teamName ?? "")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)

                                Text(host.hardwareSerial)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Image(systemName: "circle.fill")
                                    .imageScale(.small)
                                    .foregroundStyle(host.status == "online" ? .green : .red)

                                Text(host.status)
                                    .font(.body.smallCaps())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Passing Hosts",
                        systemImage: "laptopcomputer.trianglebadge.exclamationmark",
                        description: Text(
                            "There are no hosts passing this policy."
                        )
                    )
                }
            } header: {
                Label("Passing Hosts", systemImage: "checkmark.seal.fill")
            }

            Section {
                if !failingHosts.isEmpty {
                    ForEach(failingHosts) { host in
                        HStack {
                            Image(systemName: "laptopcomputer.trianglebadge.exclamationmark")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .primary)
                                .imageScale(.large)

                            VStack(alignment: .leading) {
                                Text(host.computerName)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(host.teamName ?? "")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)

                                Text(host.hardwareSerial)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Image(systemName: "circle.fill")
                                    .imageScale(.small)
                                    .foregroundStyle(host.status == "online" ? .green : .red)

                                Text(host.status)
                                    .font(.body.smallCaps())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Failing Hosts",
                        systemImage: "checkmark.seal.fill",
                        description: Text(
                            "There are no hosts failing this policy."
                        )
                    )
                }
            } header: {
                Label("Failing Hosts", systemImage: "laptopcomputer.trianglebadge.exclamationmark")
            }

            Section("Resolution") {
                Text(policy.wrappedResolution)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent(
                    "Created At",
                    value: policy.wrappedCreatedAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                LabeledContent("Created By", value: policy.wrappedAuthorName)
            }
        }
        .task {
            try? await fetchHostsForPolicy()
        }
        .navigationTitle(policy.wrappedName)
    }

    func fetchHostsForPolicy() async throws {
        let passingHostsEndpoint = Endpoint.getPassingHostsForPolicy(policyID: Int(policy.id))
        let failingHostEndpoint = Endpoint.getFailingHostsForPolicy(policyID: Int(policy.id))
        do {
            passingHosts = try await networkManager.fetch(passingHostsEndpoint)
            failingHosts = try await networkManager.fetch(failingHostEndpoint)
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error.localizedDescription)
            case .none:
                print(error.localizedDescription)
            }
        }
    }
}
