//
//  UserView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    var user: CachedUser

    var body: some View {
        Form {
            Section {
                LabeledContent("Name", value: user.wrappedName)
                LabeledContent("Email", value: user.wrappedEmail)
                LabeledContent("Created At", value: user.wrappedCreatedAt.formatted(date: .abbreviated, time: .shortened))
            }

            Section("Teams") {
                ForEach(user.teamsArray) { team in
                    HStack {
                        Text(team.wrappedName)
                        Text("\(team.id)")
                    }
                }
            }
            .navigationTitle(user.wrappedName)
        }
    }

    //    private func updateUser() async {
    //        guard dataController.activeEnvironment != nil else { return }
    //
    //        do {
    //            if let id = id {
    //                updatedUser = try await getUser(userID: Int(id))
    //            }
    //        } catch {
    //            switch error as? AuthManager.AuthError {
    //            case .missingCredentials:
    //                if !dataController.showingApiTokenAlert {
    //                    dataController.showingApiTokenAlert = true
    //                    dataController.alertTitle = "API Token Expired"
    //                    // swiftlint:disable:next line_length
    //                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
    //                }
    //            case .missingToken:
    //                print(error.localizedDescription)
    //            case .none:
    //                print(error.localizedDescription)
    //            }
    //        }
    //    }
    //
    //    func getUser(userID: Int) async throws -> User {
    //        let endpoint = Endpoint.getUser(id: userID)
    //
    //        do {
    //            let user = try await networkManager.fetch(endpoint, attempts: 5)
    //            return user
    //        } catch {
    //            print(error.localizedDescription)
    //            throw error
    //        }
    //    }
}
