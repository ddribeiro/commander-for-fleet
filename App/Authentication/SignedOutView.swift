//
//  SignedOutView.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/2/23.
//

import SwiftUI

struct SignedOutView: View {
    @State private var showingLogin = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "command")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(.tint)
            
            VStack(spacing: 12) {
                Text("Commander")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Manage your Fleet instance on the go.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button(action: {
                showingLogin.toggle()
            }) {
                HStack {
                    Text("Sign In")
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingLogin) {
            NavigationStack {
                LoginView()
                    .environmentObject(AuthService(
                        authManager: AuthManager(),
                        networkManager: NetworkManager(authManager: AuthManager()),
                        dataController: DataController(networkManager: NetworkManager(authManager: AuthManager()))
                    ))
            }
        }
    }
}

#Preview {
    SignedOutView()
}
