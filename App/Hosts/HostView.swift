//
//  HostView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 6/1/23.
//

import SwiftUI
import KeychainWrapper

struct HostView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var updatedHost: Host?
    @State private var selectedView = "Policies"
    @State private var lockCode: String = ""

    var id: Int16?
    var views = ["Policies", "Software", "Profiles"]

    var body: some View {
        if let host = updatedHost {
            Form {
                Section {
                    // swiftlint:disable:next line_length
                    let driveCapacity = ((host.gigsDiskSpaceAvailable) / Double((host.percentDiskSpaceAvailable)) * 100.0)
                    let gigsSpaceConsumed = (driveCapacity - host.gigsDiskSpaceAvailable)

                    LabeledContent("Device Name", value: host.computerName)

                    LabeledContent {
                        Text(host.hardwareSerial)
                            .monospaced()
                    } label: {
                        Text("Serial Number")
                    }

                    LabeledContent("Model", value: host.hardwareModel)

                    LabeledContent("OS Version", value: host.osVersion)

                    LabeledContent("Processor", value: host.cpuBrand)
                        .multilineTextAlignment(.trailing)

                    LabeledContent("Memory", value: "\(host.memory / 1073741824) GB")

                    if host.percentDiskSpaceAvailable != 0 {
                        Gauge(value: Double(gigsSpaceConsumed), in: 0...Double(driveCapacity)) {
                            Text("Storage")
                        } currentValueLabel: {
                            Text("\(Int(gigsSpaceConsumed)) GB of \(Int(driveCapacity)) GB used")
                                .foregroundStyle(.secondary)
                        } minimumValueLabel: {
                            Text("0 GB")
                                .foregroundStyle(.secondary)
                        } maximumValueLabel: {
                            Text("\(Int(driveCapacity)) GB")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Label("Device Information", systemImage: "laptopcomputer")
                }

                if let mdm = host.mdm {
                    if mdm.enrollmentStatus != nil {
                        Section {
                            LabeledContent("Enrollment Status", value: mdm.enrollmentStatus ?? "N/A")

                            LabeledContent("MDM Server URL", value: mdm.serverUrl ?? "N/A")
                                .multilineTextAlignment(.trailing)

                            LabeledContent("MDM Name", value: mdm.name)
                                .multilineTextAlignment(.trailing)

                            LabeledContent("Encryption Key Escrowed") {
                                Text(mdm.encryptionKeyAvailable ? "Yes" : "No")
                                    .foregroundColor(mdm.encryptionKeyAvailable ? .secondary : .red)

                                // swiftlint:disable:next line_length
                                Image(systemName: mdm.encryptionKeyAvailable ? "checkmark.shield.fill": "exclamationmark.shield.fill")
                                    .imageScale(.large)
                                    .foregroundColor(mdm.encryptionKeyAvailable ? .green : .red)
                            }
                        } header: {
                            Label("MDM Information", systemImage: "lock.laptopcomputer")
                        }
                    }
                }

                Section {

                    // swiftlint:disable:next line_length
                    LabeledContent("Enrolled", value: "\(host.lastEnrolledAt.formatted(date: .abbreviated, time: .shortened))")
                        .multilineTextAlignment(.trailing)

                    // swiftlint:disable:next line_length
                    LabeledContent("Last Seen", value: "\(host.seenTime.formatted(date: .abbreviated, time: .shortened))")
                        .multilineTextAlignment(.trailing)

                    LabeledContent("Uptime", value: "\(host.uptime / 86491509803921) days")
                }

                Section {
                    LabeledContent("IP Address", value: host.publicIp)

                    LabeledContent("Private IP Address", value: host.primaryIp)

                    LabeledContent("MAC Address", value: host.primaryMac)
                } header: {
                    Label("Network Information", systemImage: "network")
                }

                if let batteries = host.batteries {
                    Section {
                        ForEach(batteries, id: \.self) { battery in
                            Gauge(value: Double(battery.cycleCount), in: 0...1000) {
                                Text("Cycle Counts")
                            } currentValueLabel: {
                                Text("\(battery.cycleCount)")
                                    .foregroundStyle(.secondary)
                            } minimumValueLabel: {
                                Text("0")
                                    .foregroundStyle(.secondary)
                            } maximumValueLabel: {
                                Text("1000")
                                    .foregroundStyle(.secondary)
                            }
                            .tint(.green)

                            LabeledContent("Battery Health") {
                                Text(battery.health)
                                    .foregroundColor(battery.health == "Normal" ? .secondary : .red)
                                if battery.health != "Normal" {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    } header: {
                        Label("Battery Health", systemImage: "battery.100")
                    }
                }

                Section {
                    Picker("Select a view", selection: $selectedView) {
                        ForEach(views, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch selectedView {
                    case "Policies":
                        if let policies = host.policies {
                            PoliciesView(policies: policies)
                        } else {
                            ProgressView()
                        }
                    case "Software":
                        if let software = host.software {
                            HostSoftwareView(software: software)
                        } else {
                            ContentUnavailableView(
                                "No Software",
                                systemImage: "exclamationmark.triangle",
                                description: Text("This host has no software.")
                                )
                        }
                    case "Profiles":
                        if let profiles = host.mdm?.profiles {
                            ProfilesView(profiles: profiles)
                        } else {
                            ContentUnavailableView(
                                "No Profiles",
                                systemImage: "exclamationmark.triangle",
                                description: Text("This host has no profiles installed.")
                            )
                        }
                    default:
                        Text("N/A")
                    }
                }
            }
            .onChange(of: dataController.selectedHost) {
                updatedHost = nil
                Task {
                    await updateHost()
                }
            }

            .refreshable {
                await updateHost()
            }
            .sheet(isPresented: $dataController.showingApiTokenAlert) {
                APITokenRefreshView()
                    .presentationDetents([.medium])
            }
            .toolbar {
                MDMCommandMenu(host: host)
                    .disabled(host.mdm?.enrollmentStatus == nil)
            }
            .navigationTitle("\(host.computerName)")
        } else {
            ProgressView()
            Text("Loading")
                .font(.body.smallCaps())
                .foregroundColor(.secondary)

                .task {
                    await updateHost()
                }
        }

    }

    private func updateHost() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            if let id = id {
                updatedHost = try await getHost(hostID: Int(id))
            }
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

    func getHost(hostID: Int) async throws -> Host {
        let endpoint = Endpoint.gethost(id: hostID)

        do {
            let host = try await networkManager.fetch(endpoint, attempts: 5)
            return host
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
