//
//  SoilMateApp.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/1/21.
//

import SwiftUI

@main
struct SoilMateApp: App {

    // for develop
    @State private var authManager = AuthManager(isMock: false)
    
    init() {
            // Activate watch session at process launch, before any view appears.
            // This guarantees session is non-nil by the time HomeViewModel.load() runs.
            WatchConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView()
                    .environment(authManager)
            } else {
                LoginView()
                    .environment(authManager)
            }
        }
    }
}
