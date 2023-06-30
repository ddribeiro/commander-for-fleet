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
    @State var updatedHost: Host? = nil
    @State private var selectedView = "Policies"
    @State private var lockCode: String = ""
    
    @State private var showingLockAlert = false
    @State private var showingCommandSheet = false
    
    var host: Host
    var views = ["Policies", "Software", "Profiles"]
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Device Name")
                    Spacer()
                    Text(host.computerName)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Serial Number")
                    Spacer()
                    Text(host.hardwareSerial)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Model")
                    Spacer()
                    Text("\(host.hardwareModel)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("OS Version")
                    Spacer()
                    Text(host.osVersion)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Processor")
                    Spacer()
                    Text(host.cpuBrand)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Memory")
                    Spacer()
                    Text("\(host.memory / 1073741824) GB")
                        .foregroundStyle(.secondary)
                }
                
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
                        HStack {
                            Text("Enrollment Status")
                            Spacer()
                            Text(mdm.enrollmentStatus ?? "N/A")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("MDM Server URL")
                            Spacer()
                            Text(mdm.serverUrl ?? "N/A")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("MDM Name")
                            Spacer()
                            Text(mdm.name)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Encryption Key Escrowed")
                            Spacer()
                            
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
                
                HStack {
                    Text("Enrolled")
                    Spacer()
                    Text("\(host.lastEnrolledAt.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Last Seen")
                    Spacer()
                    Text("\(host.seenTime.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Uptime")
                    Spacer()
                    Text("\(host.uptime / 86491509803921) days")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                HStack {
                    Text("IP Address")
                    Spacer()
                    Text(host.publicIp)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Private IP Address")
                    Spacer()
                    Text(host.primaryIp)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("MAC Address")
                    Spacer()
                    Text(host.primaryMac)
                        .foregroundStyle(.secondary)
                }
                
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
                        
                        HStack {
                            Text("Battery Health")
                            Spacer()
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
                case "Policies" :
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
        .sheet(isPresented: $showingCommandSheet) {
            CommandsView()
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
        .alert("Enter Lock Code", isPresented: $showingLockAlert) {
            TextField("Enter your code", text: $lockCode)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) { }
            Button("Lock", role: .destructive) {
                Task {
                    let lockDeviceCommand = LockDeviceCommand(command: LockDeviceCommand.Command(pin: lockCode))
                    let mdmCommand = MdmCommand(command: try viewModel.generatebase64EncodedPlistData(from: lockDeviceCommand), deviceIds: [host.uuid])
                    
                    try await viewModel.sendMDMCommand(command: mdmCommand)
                }
            }
        } message: {
            Text("Enter a 6 digit code to lock the device")
        }
        .navigationTitle("\(host.computerName)")
        .toolbar {
            Menu {
                Menu {
                    Button {
                        Task {
                            let deviceInformationCommand = DeviceInformationCommand(command: DeviceInformationCommand.Command(queries: ["UDID", "DeviceName", "ModelName", "SerialNumber"]))
                            
                            print(deviceInformationCommand.commandUUID)
                            
                            let mdmCommand = MdmCommand(command: try viewModel.generatebase64EncodedPlistData(from: deviceInformationCommand), deviceIds: [host.uuid])
                            
                            try await viewModel.sendMDMCommand(command: mdmCommand)
                        }
                        
                    } label: {
                        Label("Get Device Information", systemImage: "info.circle")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Install Software Updates", systemImage: "arrow.down.circle")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingLockAlert.toggle()
                    } label: {
                        Label("Lock Device", systemImage: "lock.laptopcomputer")
                    }
                    
                    Button(role: .destructive) {
                        Task {
                            let shutdownDeviceCommand = ShutDownDeviceCommand(command: ShutDownDeviceCommand.Command())
                            let mdmCommand = MdmCommand(command: try viewModel.generatebase64EncodedPlistData(from: shutdownDeviceCommand), deviceIds: [host.uuid])
                            
                            try await viewModel.sendMDMCommand(command: mdmCommand)
                        }
                    } label: {
                        Label("Shutdown Device", systemImage: "power")
                    }
                    
                    Button(role: .destructive) {
                        Task {
                            let restartDeviceComand = RestartDeviceCommand(command: RestartDeviceCommand.Command())
                            let mdmCommand = MdmCommand(command: try viewModel.generatebase64EncodedPlistData(from: restartDeviceComand), deviceIds: [host.uuid])
                            
                            try await viewModel.sendMDMCommand(command: mdmCommand)
                        }
                    } label: {
                        Label("Restart Device", systemImage: "restart.circle")
                    }
                } label: {
                    Label("Send MDM Commands", systemImage: "command")
                }
                
                Menu {
                    Button {
                        Task {
                            let installZoomCommand = InstallApplicationCommand(command: InstallApplicationCommand.Command(manifestUrl: "https://storage.googleapis.com/harmonize-public/Fleetd%20Installers/zoom.plist"))
                            let mdmCommand = MdmCommand(command: try viewModel.generatebase64EncodedPlistData(from: installZoomCommand), deviceIds: [host.uuid])
                            
                            try await viewModel.sendMDMCommand(command: mdmCommand)
                        }
                        
                    } label: {
                        Label("Install Zoom", systemImage: "app.badge")
                    }
                    
                    Button {
                        Task {
                            let installChromeCommand = InstallApplicationCommand(command: InstallApplicationCommand.Command(manifestUrl: "https://storage.googleapis.com/harmonize-public/Fleetd%20Installers/GoogleChrome-114.0.5735.198.plist"))
                            let mdmCommand = MdmCommand(command: try viewModel.generatebase64EncodedPlistData(from: installChromeCommand), deviceIds: [host.uuid])
                            
                            try await viewModel.sendMDMCommand(command: mdmCommand)
                        }
                        
                    } label: {
                        Label("Install Google Chrome", systemImage: "app.badge")
                    }
                    
                    Button {
                        Task {
                            let installSlackCommand = InstallApplicationCommand(command: InstallApplicationCommand.Command(manifestUrl: "https://storage.googleapis.com/harmonize-public/Fleetd%20Installers/Slack-4.33.73.plist"))
                            let mdmCommand = MdmCommand(command: try viewModel.generatebase64EncodedPlistData(from: installSlackCommand), deviceIds: [host.uuid])
                            
                            try await viewModel.sendMDMCommand(command: mdmCommand)
                        }
                        
                    } label: {
                        Label("Install Slack", systemImage: "app.badge")
                    }
                } label: {
                    Label("Install Apps", systemImage: "laptopcomputer.and.arrow.down")
                }
                
                Divider()
                
                Button {
                    showingCommandSheet.toggle()
                } label: {
                    Label("Show Command History", systemImage: "clock")
                }
                
            } label: {
                Label("MDM Commands", systemImage: "ellipsis.circle")
            }
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


//struct HostView_Previews: PreviewProvider {
//    static var previews: some View {
//        HostView(host: .example)
//    }
//}
