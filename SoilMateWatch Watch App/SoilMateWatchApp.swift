//
//  SoilMateWatchApp.swift
//  SoilMateWatch Watch App
//
//  Created by yibagaozi on 2026/4/5.
//

import SwiftUI
import WatchConnectivity
 
@main
struct SoilMateWatchApp: App {
 
    @State private var viewModel = WatchTaskViewModel.shared
 
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(viewModel)
                .onAppear {
                    viewModel.activateSession()
                }
        }
    }
}
