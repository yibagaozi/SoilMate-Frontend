//
//  ContentView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/1/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "leaf.fill")
                }

            MyGardenView()
                .tabItem {
                    Label("My Garden", systemImage: "square.grid.2x2")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.mint)
    }
}


#Preview {
    ContentView()
        .environment(AuthManager())
}
