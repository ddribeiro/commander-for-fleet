//
//  MDMCommandMenu.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/17/23.
//

import SwiftUI
import KeychainWrapper

struct MDMCommandMenu: View {
    var host: Host

    @State private var lockCode: String = ""
    @State private var showingLockAlert = false
    @State private var showingCommandSheet = false
    @Environment(\.networkManager) var networkManager

    var body: some View {
        Menu {
//            Menu {
//                Button {
//                    Task {
//                        let deviceInformationCommand = DeviceInformationCommand(
//                            command: DeviceInformationCommand.Command(
//                                queries: [
//                                    "AccessibilitySettings",
//                                    "ActiveManagedUsers",
//                                    "AppAnalyticsEnabled",
//                                    "AutoSetupAdminAccounts",
//                                    "AvailableDeviceCapacity",
//                                    "AwaitingConfiguration",
//                                    "BatteryLevel",
//                                    "BluetoothMAC",
//                                    "BuildVersion",
//                                    "CellularTechnology",
//                                    "DataRoamingEnabled",
//                                    "DeviceCapacity",
//                                    "DeviceID",
//                                    "DeviceName",
//                                    "DevicePropertiesAttestation",
//                                    "DiagnosticSubmissionEnabled",
//                                    "EACSPreflight",
//                                    "EASDeviceIdentifier",
//                                    "EstimatedResidentUsers",
//                                    "EthernetMAC",
//                                    "HasBattery",
//                                    "HostName",
//                                    "IsActivationLockSupported",
//                                    "IsAppleSilicon",
//                                    "IsCloudBackupEnabled",
//                                    "IsDeviceLocatorServiceEnabled",
//                                    "IsDoNotDisturbInEffect",
//                                    "IsMDMLostModeEnabled",
//                                    "IsMultiUser",
//                                    "IsNetworkTethered",
//                                    "IsRoaming",
//                                    "IsSupervised",
//                                    "iTunesStoreAccountHash",
//                                    "iTunesStoreAccountIsActive",
//                                    "LastCloudBackupDate",
//                                    "LocalHostName",
//                                    "ManagedAppleIDDefaultDomains",
//                                    "MaximumResidentUsers",
//                                    "MDMOptions",
//                                    "Model",
//                                    "ModelName",
//                                    "ModemFirmwareVersion",
//                                    "ModelNumber",
//                                    "OnlineAuthenticationGracePeriod",
//                                    "OrganizationInfo",
//                                    "OSUpdateSettings",
//                                    "OSVersion",
//                                    "PersonalHotspotEnabled",
//                                    "PINRequiredForDeviceLock",
//                                    "PINRequiredForEraseDevice",
//                                    "ProductName",
//                                    "ProvisioningUDID",
//                                    "PushToken",
//                                    "QuotaSize",
//                                    "ResidentUsers",
//                                    "SerialNumber",
//                                    "ServiceSubscriptions",
//                                    "SkipLanguageAndLocaleSetupForNewUsers",
//                                    "SoftwareUpdateDeviceID",
//                                    "SoftwareUpdateSettings",
//                                    "SupplementalBuildVersion",
//                                    "SupplementalOSVersionExtra",
//                                    "SupportsiOSAppInstalls",
//                                    "SupportsLOMDevice",
//                                    "SystemIntegrityProtectionEnabled",
//                                    "TemporarySessionOnly",
//                                    "TemporarySessionTimeout",
//                                    "TimeZone",
//                                    "UDID",
//                                    "UserSessionTimeout",
//                                    "WiFiMAC"
//                                ]
//                            )
//                        )
//
//                        let mdmCommand = MdmCommand(
//                            command: try generatebase64EncodedPlistData(from: deviceInformationCommand),
//                            deviceIds: [host.uuid]
//                        )
//
//                        try await sendMDMCommand(command: mdmCommand)
//                    }
//
//                } label: {
//                    Label("Get Device Information", systemImage: "info.circle")
//                }
//
//                Divider()
//
//                Button(role: .destructive) {
//                    showingLockAlert.toggle()
//                } label: {
//                    Label("Lock Device", systemImage: "lock.laptopcomputer")
//                }
//
//                Button(role: .destructive) {
//                    Task {
//                        let shutdownDeviceCommand = ShutDownDeviceCommand(command: ShutDownDeviceCommand.Command())
//                        // swiftlint:disable:next line_length
//                        let mdmCommand = MdmCommand(command: try generatebase64EncodedPlistData(from: shutdownDeviceCommand), deviceIds: [host.uuid])
//
//                        try await sendMDMCommand(command: mdmCommand)
//                    }
//                } label: {
//                    Label("Shutdown Device", systemImage: "power")
//                }
//
//                Button(role: .destructive) {
//                    Task {
//                        let restartDeviceComand = RestartDeviceCommand(command: RestartDeviceCommand.Command())
//
//                        // swiftlint:disable:next line_length
//                        let mdmCommand = MdmCommand(command: try generatebase64EncodedPlistData(from: restartDeviceComand), deviceIds: [host.uuid])
//
//                        try await sendMDMCommand(command: mdmCommand)
//                    }
//                } label: {
//                    Label("Restart Device", systemImage: "restart.circle")
//                }
//            } label: {
//                Label("Send MDM Commands", systemImage: "command")
//            }

//            Menu {
//                Button {
//                    Task {
//                        let installZoomCommand = InstallApplicationCommand(
//                            command: InstallApplicationCommand.Command(
//                                // swiftlint:disable:next line_length
//                                manifestUrl: "https://storage.googleapis.com/harmonize-public/Fleetd%20Installers/zoom.plist"
//                            )
//                        )
//
//                        let mdmCommand = MdmCommand(
//                            command: try generatebase64EncodedPlistData(from: installZoomCommand),
//                            deviceIds: [host.uuid]
//                        )
//
//                        try await sendMDMCommand(command: mdmCommand)
//                    }
//
//                } label: {
//                    Label("Install Zoom", systemImage: "app.badge")
//                }
//
//                Button {
//                    Task {
//                        let installChromeCommand = InstallApplicationCommand(
//                            command: InstallApplicationCommand.Command(
//                                // swiftlint:disable:next line_length
//                                manifestUrl: "https://storage.googleapis.com/harmonize-public/Fleetd%20Installers/GoogleChrome-114.0.5735.198.plist"
//                            )
//                        )
//                        let mdmCommand = MdmCommand(
//                            command: try generatebase64EncodedPlistData(from: installChromeCommand),
//                            deviceIds: [host.uuid]
//                        )
//
//                        try await sendMDMCommand(command: mdmCommand)
//                    }
//
//                } label: {
//                    Label("Install Google Chrome", systemImage: "app.badge")
//                }
//
//                Button {
//                    Task {
//                        let installSlackCommand = InstallApplicationCommand(
//                            command: InstallApplicationCommand.Command(
//                                // swiftlint:disable:next line_length
//                                manifestUrl: "https://storage.googleapis.com/harmonize-public/Fleetd%20Installers/Slack-4.33.73.plist"
//                            )
//                        )
//                        let mdmCommand = MdmCommand(
//                            command: try generatebase64EncodedPlistData(from: installSlackCommand),
//                            deviceIds: [host.uuid]
//                        )
//
//                        try await sendMDMCommand(command: mdmCommand)
//                    }
//
//                } label: {
//                    Label("Install Slack", systemImage: "app.badge")
//                }
//            } label: {
//                Label("Install Apps", systemImage: "laptopcomputer.and.arrow.down")
//            }

            Divider()

            Button {
                showingCommandSheet.toggle()
            } label: {
                Label("Show Command History", systemImage: "clock")
            }

        } label: {
            Label("MDM Commands", systemImage: "ellipsis.circle")
        }
        .sheet(isPresented: $showingCommandSheet) {
            CommandsView(host: host)
        }
        .alert("Enter Lock Code", isPresented: $showingLockAlert) {
            TextField("Enter your code", text: $lockCode)
            #if os(iOS)
                .keyboardType(.numberPad)
            #endif
            Button("Cancel", role: .cancel) { }
            Button("Lock", role: .destructive) {
                Task {
                    let lockDeviceCommand = LockDeviceCommand(
                        command: LockDeviceCommand.Command(
                            pin: lockCode
                        )
                    )

                    let mdmCommand = MdmCommand(
                        command: try generatebase64EncodedPlistData(from: lockDeviceCommand),
                        deviceIds: [host.uuid]
                    )

                    try await sendMDMCommand(command: mdmCommand)
                }
            }
        }
    }

    func generatebase64EncodedPlistData<T: Encodable>(from object: T) throws -> String {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        do {
            let plistData = try encoder.encode(object)
            return plistData.base64EncodedString().replacingOccurrences(of: "=", with: "")
        } catch {
            print("Error generating plist data: \(error)")
            return error.localizedDescription
        }
    }

    func sendMDMCommand(command: MdmCommand) async throws {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase

            _ = try await networkManager.fetch(.mdmCommand, with: encoder.encode(command))
        } catch {
            print("Could not send command")
            print(error.localizedDescription)
        }
    }
}
