//
//  SettingsView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI

struct SettingsView: View {

    private let headerHeight: CGFloat = 48

    @State private var enableReminders = true
    @State private var syncCalendar = true
    @State private var sound = "Default"
    
    @State private var reminderTime = {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    private let presetSound = ["Default", "Note", "Glass", "Bell", "Signal", "Pulse", "Tri-tone"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
                // MARK: Header
                header

                // MARK: List
                List {
                    // ── Profile ──
                    Section {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 24))
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Rachel")
                                    .font(.system(size: 18, weight: .semibold))
                                Text(verbatim: "rachel1211@gmail.com")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                            }

                            Spacer()

                            HStack(spacing: 4) {
                                Text("Detail")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                        .padding(.vertical, 4)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }

                        // logout
                        Button(role: .destructive) {
                            print("Logout")
                        } label: {
                            HStack {
                                Spacer()
                                Text("Logout")
                                Spacer()
                            }
                        }
                        .listRowSeparator(.hidden, edges: .bottom)
                    }

                    // ── Notifications ──
                    Section("Notifications") {
                        Toggle("Enable Reminders", isOn: $enableReminders)
                            .tint(.mint)

                        DatePicker("Reminder Time",
                                   selection: $reminderTime,
                                   displayedComponents: .hourAndMinute)
                        .tint(.mint)
                        
                        HStack {
                            Text("Sound")
                            Spacer()
                            Menu {
                                ForEach(presetSound, id: \.self) { option in
                                    Button(option) { sound = option }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(sound)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(.tertiaryLabel))
                                }
                            }
                        }
                    }

                    // ── Calendar ──
                    Section("Calendar") {
                        Toggle("Sync Calendar", isOn: $syncCalendar)
                            .tint(.mint)
                    }

                    // ── About ──
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("V1.0.0")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Privacy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }

                        HStack {
                            Text("Contact Us")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .listSectionSpacing(.compact)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .tint(nil)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 0)
        .frame(height: headerHeight, alignment: .center)
    }
}

#Preview {
    SettingsView()
}
