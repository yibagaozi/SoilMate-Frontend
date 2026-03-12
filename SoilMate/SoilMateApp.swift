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
