//
//  SignInUpView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/29/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import AuthenticationServices
//import FirebaseAuthUI
//import FirebaseCore
//import FirebaseFacebookAuthUI
//import FirebaseGoogleAuthUI
//import FirebaseOAuthUI
//import FirebasePhoneAuthUI

struct SignInUpView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var showSignIn: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "logo")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 400)
            
            Color.clear.background(.ultraThinMaterial)
            
            VStack {
                Spacer()
                
                Image(uiImage: UIImage(named: "logo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
//                    .opacity(0.5)
                    .shadow(radius: 10)
                
                Text("StatBeast | Hoops")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .shadow(radius: 10)
                
                Text("Sign in or Sign up to get started")
                    .font(.footnote)
                    .fontWeight(.light)
                    .shadow(radius: 10)
                
                Divider().padding()
                
//                Spacer()
//                
//                TextField("Email", text: $email)
//                    .textFieldStyle(.roundedBorder)
//                
//                TextField("Password", text: $password)
//                    .textFieldStyle(.roundedBorder)
                
                Spacer()
                
                SignInWithAppleButton(
                    onRequest: { request in
                        AppleSignInManager.shared.requestAppleAuthorization(request)
                    },
                    onCompletion: { result in
                        handleAppleID(result)
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                .frame(width: 280, height: 45, alignment: .center)
                
                if authManager.authState == .signedOut {
                    Button {
                        signAnonymously()
                    } label: {
                        Text("Skip")
                            .font(.body.bold())
                            .frame(width: 280, height: 45, alignment: .center)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    func signAnonymously() {
        Task {
            do {
                let result = try await authManager.signInAnonymously()
                
                if result?.user != nil {
                    showSignIn = false
                }
            }
            catch {
                print("SignInAnonymouslyError: \(error)")
            }
        }
    }
    
    func handleAppleID(_ result: Result<ASAuthorization, Error>) {
        if case let .success(auth) = result {
            guard let appleIDCredentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                print("AppleAuthorization failed: AppleID credential not available")
                return
            }

            Task {
                do {
                    let result = try await authManager.appleAuth(
                        appleIDCredentials,
                        nonce: AppleSignInManager.nonce
                    )
                    if let result = result {
                        dismiss()
                    }
                } catch {
                    print("AppleAuthorization failed: \(error)")
                    // Here you can show error message to user.
                }
            }
        }
        else if case let .failure(error) = result {
            print("AppleAuthorization failed: \(error)")
            // Here you can show error message to user.
        }
    }
}

#Preview {
    SignInUpView(showSignIn: .constant(true)).environmentObject(AuthManager())
}
