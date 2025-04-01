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
            Menu {

                Button(role: .destructive) {
                    showingLockAlert.toggle()
                } label: {
                    Label("Lock Device", systemImage: "lock.laptopcomputer")
                }

                Button(role: .destructive) {
                    Task {
                        let shutdownDeviceCommand = ShutDownDeviceCommand(command: ShutDownDeviceCommand.Command())
                        // swiftlint:disable:next line_length
                        let mdmCommand = MdmCommand(command: try generatebase64EncodedPlistData(from: shutdownDeviceCommand), deviceIds: [host.uuid])

                        try await sendMDMCommand(command: mdmCommand)
                    }
                } label: {
                    Label("Shutdown Device", systemImage: "power")
                }

                Button(role: .destructive) {
                    Task {
                        let restartDeviceComand = RestartDeviceCommand(command: RestartDeviceCommand.Command())

                        // swiftlint:disable:next line_length
                        let mdmCommand = MdmCommand(command: try generatebase64EncodedPlistData(from: restartDeviceComand), deviceIds: [host.uuid])

                        try await sendMDMCommand(command: mdmCommand)
                    }
                } label: {
                    Label("Restart Device", systemImage: "restart.circle")
                }
            } label: {
                Label("Send MDM Commands", systemImage: "command")
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
        .sheet(isPresented: $showingCommandSheet) {
            HostCommandsView(host: host)
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
