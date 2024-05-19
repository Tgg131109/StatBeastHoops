//
//  AuthManager.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 5/17/24.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseCore

enum AuthState {
    case authenticated // Anonymously authenticated in Firebase.
    case signedIn // Authenticated in Firebase using one of service providers, and not anonymous.
    case signedOut // Not authenticated in Firebase.
}

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var authState = AuthState.signedOut
    
    private var authStateHandle: AuthStateDidChangeListenerHandle!

    private let authLinkErrors: [AuthErrorCode.Code] = [
            .emailAlreadyInUse,
            .credentialAlreadyInUse,
            .providerAlreadyLinked
    ]
    
    init() {
        configureAuthStateChanges()
        verifySignInWithAppleID()
    }
    
    func configureAuthStateChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { auth, user in
            print("Auth changed: \(user != nil)")
            
            self.updateState(user: user)
        }
    }
    
    func removeAuthStateListener() {
        Auth.auth().removeStateDidChangeListener(authStateHandle)
    }
    
    func updateState(user: User?) {
        self.user = user
        let isAuthenticatedUser = user != nil
        let isAnonymous = user?.isAnonymous ?? false

        if isAuthenticatedUser {
            self.authState = isAnonymous ? .authenticated : .signedIn
        } else {
            self.authState = .signedOut
        }
    }
    
    func signInAnonymously() async throws -> AuthDataResult? {
        do {
            let result = try await Auth.auth().signInAnonymously()
            
            print("FirebaseAuthSuccess: Sign in anonymously, UID:(\(String(describing: result.user.uid)))")
            
            return result
        } catch {
            print("FirebaseAuthError: failed to sign in anonymously: \(error.localizedDescription)")
            
            throw error
        }
    }
    
    func appleAuth(
        _ appleIDCredential: ASAuthorizationAppleIDCredential,
        nonce: String?
    ) async throws -> AuthDataResult? {
        guard let nonce = nonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return nil
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return nil
        }
        
        let credentials = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: appleIDCredential.fullName)

        do {
            return try await authenticateUser(credentials: credentials)
        } catch {
            print("FirebaseAuthError: appleAuth(appleIDCredential:nonce:) failed. \(error)")
            throw error
        }
    }
    
    private func authenticateUser(credentials: AuthCredential) async throws -> AuthDataResult? {
        if Auth.auth().currentUser != nil {
            return try await authLink(credentials: credentials)
        } else {
            return try await authSignIn(credentials: credentials)
        }
    }
    
    private func authSignIn(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            let result = try await Auth.auth().signIn(with: credentials)
            
            updateState(user: result.user)
            
            return result
        } catch {
            print("FirebaseAuthError: signIn(with:) failed. \(error)")
            
            throw error
        }
    }
    
    private func authLink(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            guard let user = Auth.auth().currentUser else { return nil }
            let result = try await user.link(with: credentials)
            await updateDisplayName(for: result.user)
            
            updateState(user: result.user)
            
            return result
        } catch {
            if let error = error as NSError? {
                if let code = AuthErrorCode.Code(rawValue: error.code), authLinkErrors.contains(code) {
                    let appleCredentials = credentials.provider == "apple.com" ? error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential : nil

                    return try await self.authSignIn(credentials: appleCredentials ?? credentials)
                }
            }
            print("FirebaseAuthError: link(with:) failed, \(error)")
            
            throw error
        }
    }
    
    func verifySignInWithAppleID() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let providerData = Auth.auth().currentUser?.providerData
        
        if let appleProviderData = providerData?.first(where: { $0.providerID == "apple.com" }) {
            Task {
                let credentialState = try await appleIDProvider.credentialState(forUserID: appleProviderData.uid)
                switch credentialState {
                case .authorized:
                    break // The Apple ID credential is valid.
                case .revoked, .notFound:
                    // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                    do {
                        try await self.signOut()
                    }
                    catch {
                        print("FirebaseAuthError: signOut() failed. \(error)")
                    }
                default:
                    break
                }
            }
        }
    }
    
    func signOut() async throws {
        if let user = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                print("FirebaseAuthError: failed to sign out from Firebase, \(error)")
                
                throw error
            }
        }
    }
    
    private func updateDisplayName(for user: User) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty {
            // current user is non-empty, don't overwrite it
        } else  {
            let displayName = user.providerData.first?.displayName
            let changeRequest = user.createProfileChangeRequest()
            
            changeRequest.displayName = displayName
            do {
                try await changeRequest.commitChanges()
            } catch {
                print("FirebaseAuthError: Failed to update the user's displayName. \(error.localizedDescription)")
            }
        }
    }
}

import AuthenticationServices
import CryptoKit

class AppleSignInManager {
    
    static let shared = AppleSignInManager()

    fileprivate static var currentNonce: String?

    static var nonce: String? {
        currentNonce ?? nil
    }

    private init() {}

    func requestAppleAuthorization(_ request: ASAuthorizationAppleIDRequest) {
        AppleSignInManager.currentNonce = randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(AppleSignInManager.currentNonce!)
    }
}

extension AppleSignInManager {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
