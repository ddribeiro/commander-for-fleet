//
//  HostView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 6/1/23.
//

import SwiftUI
import KeychainWrapper

struct HostView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var updatedHost: Host?
    @State private var selectedView = "Policies"
    @State private var lockCode: String = ""

    var host: Host
    var views = ["Policies", "Software", "Profiles"]

    var body: some View {
        Form {
            Section {
                LabeledContent("Device Name", value: host.computerName)

                LabeledContent("Serial Number", value: host.hardwareSerial)

                LabeledContent("Model", value: host.hardwareSerial)

                LabeledContent("OS Version", value: host.osVersion)

                LabeledContent("Processor", value: host.cpuBrand)
                    .multilineTextAlignment(.trailing)

                LabeledContent("Memory", value: "\(host.memory / 1073741824) GB")

                if let updatedHost = updatedHost {
                    let driveCapacity = ((updatedHost.gigsDiskSpaceAvailable) / Double((updatedHost.percentDiskSpaceAvailable)) * 100.0)
                    let gigsSpaceConsumed = (driveCapacity - updatedHost.gigsDiskSpaceAvailable)

                    Gauge(value: Double(gigsSpaceConsumed), in: 0...Double(driveCapacity)) {
                        Text("Available Storage")
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

            if let mdm = updatedHost?.mdm {
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
                LabeledContent("Enrolled", value: "\(host.lastEnrolledAt.formatted(date: .abbreviated, time: .shortened))")
                    .multilineTextAlignment(.trailing)

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

            if let batteries = updatedHost?.batteries {
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
                } footer: {
                    // swiftlint:disable:next line_length
                    Text("Batteries have a limited amount of charge cycles before their performance is expected to diminish. Once the cycle count is reached, a replacement battery is recommended to maintain performance. A modern Mac laptop batteries are rated for 1000 charge cycles until it is considered consumed.")
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
                    if let policies = updatedHost?.policies {
                        PoliciesView(policies: policies)
                    } else {
                        ProgressView()
                    }
                case "Software":
                    if let software = updatedHost?.software {
                        SoftwareView(software: software)
                    } else {
                        ProgressView()
                    }
                case "Profiles":
                    if let profiles = updatedHost?.mdm?.profiles {
                        ProfilesView(profiles: profiles)
                    } else {
                        ProgressView()
                    }
                default:
                    Text("N/A")
                }
            }
        }

        .onChange(of: viewModel.selectedHost) { _ in
            updatedHost = nil
            Task {
                await updateHost()
            }
        }
        .refreshable {
            await updateHost()
        }
        .task {
            await updateHost()
        }
        .navigationTitle("\(host.computerName)")
        .toolbar {
            MDMCommandMenu(host: host)
            .disabled(updatedHost?.mdm?.enrollmentStatus == nil)
        }
    }

    private func updateHost() async {
        do {
            if let id = viewModel.selectedHost?.id {
                updatedHost = try await viewModel.getHost(hostID: id)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

 struct HostView_Previews: PreviewProvider {
    static var previews: some View {
        HostView(host: .example)
            .environmentObject(ViewModel())
    }
 }
