//
//  MeView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/22/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataContoller: DataController
    @Environment(\.dismiss) var dismiss
    @State private var isSignOutAlertPresented = false
    var body: some View {
        NavigationView {
            if let user = dataContoller.currentUser {
                Form {
                    Section {
                        HStack {
                            if user.gravatarUrl.isEmpty {
                                Image(systemName: "person.fill")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.accentColor.gradient, in: Circle())
                            } else {
                                AsyncImage(url: URL(string: "\(user.gravatarUrl)?s=240")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(.white, lineWidth: 2)
                                        }
                                        .shadow(radius: 7)

                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 60, height: 60)

                            }

                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.medium)

                                Text(user.email)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Section {
                        LabeledContent("Role", value: user.globalRole.capitalized)

                        LabeledContent("Created On", value: user.createdAt.formatted(date: .abbreviated, time: .omitted))
                    }

                    Section {
                        ForEach(user.teams) { team in
                            Text(team.name)
                        }
                    } header: {
                        Text("Available Teams")
                    }

                    Section {
                        LabeledContent("Sign Out") {
                            Button("Sign Out", role: .destructive) {
                                isSignOutAlertPresented = true
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .labelsHidden()
                    }
                }
                .formStyle(.grouped)
                .alert(isPresented: $isSignOutAlertPresented) {
                    signOutAlert
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .navigationTitle("Account")
            } else {
                Text("No user found")
            }
        }
    }

    private var signOutAlert: Alert {
        Alert(
            title: Text("Are you sure you want to sign out?"),
            primaryButton: .destructive(Text("Sign Out")) {

            },
            secondaryButton: .cancel()
        )
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataController())
    }
}
