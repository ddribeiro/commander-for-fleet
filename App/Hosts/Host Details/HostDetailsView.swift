//
//  HostDetailsView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 6/1/23.
//

import SwiftUI
import KeychainWrapper

struct HostDetailsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager
    
    @State private var updatedHost: Host?
    @State private var selectedView = "Policies"
    @State private var lockCode: String = ""
    
    var id: Int
    var views = ["Policies", "Software", "Profiles"]
    
    var body: some View {
        if let host = updatedHost {
            Form {
                HostHardwareDetailsView(host: host)
                HostStorageDetailsView(host: host)
                
                if let mdm = host.mdm {
                    if mdm.enrollmentStatus != nil {
                        HostMDMDetailsView(mdm: mdm)
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
                            HostPoliciesView(policies: policies)
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
                            HostProfilesView(profiles: profiles)
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
            .onDisappear {
                updatedHost = nil
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
            
                .task {
                    await updateHost()
                }
        }
        
    }
    
    private func updateHost() async {
        guard dataController.activeEnvironment != nil else { return }
        
        do {
            updatedHost = try await getHost(hostID: Int(id))
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
                print(error)
            case .none:
                print(error)
            }
        }
    }
    
    func getHost(hostID: Int) async throws -> Host {
        let endpoint = Endpoint.gethost(id: hostID)
        
        do {
            let host = try await networkManager.fetch(endpoint, attempts: 5)
            return host
        } catch {
            print(error)
            throw error
        }
    }
}
