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

    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Activate watch session at process launch, before any view appears.
        // This guarantees session is non-nil by the time HomeViewModel.load() runs.
        WatchConnectivityManager.shared.activate()

        // Start watching the network so the offline queue can be flushed
        // automatically when connectivity returns.
        NetworkMonitor.shared.start()
        
        
        Task { await NotificationManager.shared.requestAuthorization() }
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
        .onChange(of: scenePhase) { _, phase in
            // When the app comes back to the foreground, try to send any
            // queued task updates that piled up while we were offline.
            if phase == .active {
                Task { await PendingUpdateQueue.shared.flush() }
            }
        }
    }
}
