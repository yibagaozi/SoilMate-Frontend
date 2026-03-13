//
//  SettingsView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI

struct SettingsView: View {

    @Environment(AuthManager.self) private var authManager
    @State private var viewModel = SettingsViewModel()

    private let headerHeight: CGFloat = 48
    private let presetSound = ["Default", "Note", "Glass", "Bell", "Signal", "Pulse", "Tri-tone"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {
                header

                List {
                    // MARK: - Profile
                    Section {
                        HStack(spacing: 14) {
                            // Avatar
                            if let urlStr = viewModel.avatarUrl, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    avatarPlaceholder
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                avatarPlaceholder
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(viewModel.displayName.isEmpty ? "User" : viewModel.displayName)
                                    .font(.system(size: 18, weight: .semibold))
                                Text(viewModel.email)
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

                        // Logout button
                        Button(role: .destructive) {
                            authManager.logout()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Logout")
                                Spacer()
                            }
                        }
                        .listRowSeparator(.hidden, edges: .bottom)
                    }

                    // MARK: - Notifications
                    Section("Notifications") {
                        Toggle("Enable Reminders", isOn: $viewModel.notificationEnabled)
                            .tint(.mint)
                            .onChange(of: viewModel.notificationEnabled) { _, _ in
                                Task { await viewModel.saveSettings() }
                            }

                        DatePicker("Reminder Time",
                                   selection: $viewModel.reminderTime,
                                   displayedComponents: .hourAndMinute)
                        .tint(.mint)
                        .onChange(of: viewModel.reminderTime) { _, _ in
                            Task { await viewModel.saveSettings() }
                        }

                        HStack {
                            Text("Sound")
                            Spacer()
                            Menu {
                                ForEach(presetSound, id: \.self) { option in
                                    Button(option) { viewModel.sound = option }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.sound)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(.tertiaryLabel))
                                }
                            }
                        }
                    }

                    // MARK: - Calendar
                    Section("Calendar") {
                        Toggle("Sync Calendar", isOn: $viewModel.syncCalendar)
                            .tint(.mint)
                    }

                    // MARK: - About
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("V1.0.0").foregroundColor(.secondary)
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
            .task {
                await viewModel.load()
            }
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

    // MARK: - Avatar Placeholder

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
            )
    }
}

#Preview {
    SettingsView()
        .environment(AuthManager())
}
