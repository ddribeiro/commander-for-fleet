//
//  SignedOutView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/2/23.
//

import SwiftUI

struct SignedOutView: View {
    @State private var showingLogin = false

    var body: some View {
        ContentUnavailableView {
         Label("Signed Out", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("Sign in with your Fleet Server URL, Email Address and Password")
        } actions: {
            Button("Sign In") {
                showingLogin.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showingLogin, content: LoginView.init)
    }
}

#Preview {
    SignedOutView()
}
