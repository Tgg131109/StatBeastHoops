//
//  StatBeastHoopsApp.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct StatBeastHoopsApp: App {
//    @StateObject var authManager: AuthManager
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    init() {
////        FirebaseApp.configure()
//        // Initialize authManager.
//        let authManager = AuthManager()
//        _authManager = StateObject(wrappedValue: authManager)
//    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
//                .environmentObject(authManager)
        }
    }
}
