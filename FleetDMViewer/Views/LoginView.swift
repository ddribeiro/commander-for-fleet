//
//  LoginView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 5/22/23.
//

import SwiftUI
import KeychainWrapper

struct LoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }
}

enum LoadingState {
    case loading, loaded, failed
}

struct LoginView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var loadingState = LoadingState.loaded
    
    var body: some View {
        NavigationStack {
            Spacer()
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Enter your Fleet Server URL and sign in with your Email Address and Password")
                    .padding(.bottom)
                
                VStack {
                    
                    VStack (alignment: .leading) {
                        Text("FleetDM Server URL")
                            .font(.headline)
                        TextField("Enter server URL", text: $viewModel.serverURL)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .textFieldStyle(LoginTextFieldStyle())
                    }
                    .padding(.bottom)
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Email Address and Password")
                            .font(.headline)
                        TextField("Enter email address", text: $viewModel.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(LoginTextFieldStyle())
                    }
                    .padding(.top)
                    
                    VStack(alignment: .leading) {
                        
                        SecureField("Enter password", text: $viewModel.password)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textFieldStyle(LoginTextFieldStyle())
                    }
                }
                .padding(.bottom, 30)
                
                Button {
                    loadingState = .loading
                    viewModel.saveCredentials()
                    
                    Task {
                        try? await viewModel.login(email: viewModel.emailAddress, password: viewModel.password)
                        loadingState = .loaded
                    }
                } label: {
                    switch loadingState {
                    case .loaded:
                        Text("Log in")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    case .loading:
                        ProgressView()
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    case .failed:
                        Text("Log in")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
            }
            .alert("Login Error", isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Incorrect username or password.")
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
