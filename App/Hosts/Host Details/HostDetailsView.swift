//
//  HostDetailsView.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/1/23.
//

import SwiftUI

struct HostDetailsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var updatedHost: Host?

    private enum HostDetailPane: String, CaseIterable, Identifiable {
        case policies = "Policies"
        case software = "Software"
        case profiles = "Profiles"
        var id: String { rawValue }
    }

    @State private var selectedPane: HostDetailPane = .policies

    var id: Int?

    var body: some View {
        Group {
            if let host = updatedHost {
                List {
                    Section {
                        HostHardwareDetailsView(host: host)
                    } header: {
                        Label("Device Information", systemImage: "laptopcomputer")
                    }

                    Section {
                        HostStorageDetailsView(host: host)
                    } header: {
                        Label("Storage", systemImage: "internaldrive")
                    }

                    if let mdm = host.mdm, mdm.enrollmentStatus != nil {
                        Section {
                            HostMDMDetailsView(mdm: mdm)
                        } header: {
                            Label("MDM Information", systemImage: "lock.laptopcomputer")
                        }
                    }

                    Section {
                        LabeledContent("Enrolled") {
                            Text(host.lastEnrolledAt.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent("Last Seen") {
                            Text(host.seenTime.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent("Uptime") {
                            Text(formattedUptime(Double(host.uptime)))
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Label("Activity", systemImage: "clock")
                    }

                    Section {
                        LabeledContent("IP Address", value: host.publicIp)
                        LabeledContent("Private IP Address", value: host.primaryIp)
                        LabeledContent("MAC Address", value: host.primaryMac)
                    } header: {
                        Label("Network", systemImage: "network")
                    }

                    if let batteries = host.batteries, !batteries.isEmpty {
                        Section {
                            ForEach(batteries, id: \.self) { battery in
                                VStack(alignment: .leading, spacing: 8) {
                                    Gauge(value: battery.health ?? 1.0, in: 0...1) {
                                        Text("Health")
                                    } currentValueLabel: {
                                        Text(batteryHealthLabel(for: battery))
                                            .foregroundStyle(.secondary)
                                    }
                                    .tint((battery.health ?? 1.0) < 0.8 ? .orange : .green)

                                    LabeledContent("Cycle Count", value: "\(battery.cycleCount)")

                                    if (battery.health ?? 1.0) < 0.8 {
                                        Label(
                                            "Battery health is below 80%",
                                            systemImage: "exclamationmark.triangle.fill"
                                        )
                                        .foregroundStyle(.orange)
                                        .font(.footnote)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } header: {
                            Label("Battery", systemImage: "battery.100")
                        }
                    }

                    Section {
                        NavigationLink(value: HostDetailPane.policies) {
                            Label("Policies", systemImage: paneIcon(for: .policies))
                        }
                        NavigationLink(value: HostDetailPane.software) {
                            Label("Software", systemImage: paneIcon(for: .software))
                        }

                        if let profiles = host.mdm?.profiles, !profiles.isEmpty {
                            NavigationLink(value: HostDetailPane.profiles) {
                                Label("Profiles", systemImage: paneIcon(for: .profiles))
                            }
                        }
                    } header: {
                        Label("Management", systemImage: "gearshape")
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await updateHost()
                }
                .sheet(isPresented: $dataController.showingApiTokenAlert) {
                    APITokenRefreshView()
                        .presentationDetents([.medium])
                }
                .alert(dataController.alertTitle, isPresented: $dataController.showingAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(dataController.alertDescription)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        MDMCommandMenu(host: host)
                            .disabled(host.mdm?.enrollmentStatus == nil)
                    }
                }
                .navigationTitle(host.computerName)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView(
                    "Loading Host",
                    systemImage: "desktopcomputer",
                    description: Text("Fetching the latest details…")
                )
            }
        }
        .task {
            await updateHost()
        }
        .navigationDestination(for: HostDetailPane.self) { pane in
            switch pane {
            case .policies:
                if let policies = updatedHost?.policies {
                    HostPoliciesView(policies: policies)
                } else {
                    ContentUnavailableView("No Policies", systemImage: "list.bullet", description: Text("This host has no policies installed."))
                }
            case .software:
                if let software = updatedHost?.software, !software.isEmpty {
                    HostSoftwareView(software: software)
                } else {
                    ContentUnavailableView("No Software", systemImage: "app.badge", description: Text("This host has no software installed."))
                }
            case .profiles:
                if let profiles = updatedHost?.mdm?.profiles, !profiles.isEmpty {
                    HostProfilesView(profiles: profiles)
                } else {
                    ContentUnavailableView("No Profiles", systemImage: "switch.2", description: Text("This host has no profiles installed."))
                }
            }
        }
    }

    /// Shows Fleet's reported health text (e.g. "Service recommended") when
    /// available, otherwise the percentage derived from the numeric level.
    private func batteryHealthLabel(for battery: Battery) -> String {
        if let healthText = battery.healthText {
            return healthText
        }
        return (battery.health ?? 1.0).formatted(.percent.precision(.fractionLength(0)))
    }

    private func paneIcon(for pane: HostDetailPane) -> String {
        switch pane {
        case .policies:
            return "list.bullet"
        case .software:
            return "app.badge"
        case .profiles:
            return "switch.2"
        }
    }

    private func updateHost() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            if let id = id {
                updatedHost = try await getHost(hostID: id)
            }
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken, .none:
                print(error)
            }
        }
    }

    private func formattedUptime(_ raw: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: raw) ?? "—"
    }

    func getHost(hostID: Int) async throws -> Host {
        let endpoint = Endpoint.getHost(id: hostID)

        // NetworkManager logs the URL, status, and response body on failure.
        return try await networkManager.fetch(endpoint, attempts: 5)
    }
}
