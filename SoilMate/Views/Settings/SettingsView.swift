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
    @State private var calendarManager = CalendarManager.shared
    @State private var showCalendarDenied = false

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
                        Toggle("Sync to Calendar", isOn: $viewModel.syncCalendar)
                            .tint(.mint)
                            .onChange(of: viewModel.syncCalendar) { _, enabled in
                                Task { await handleCalendarToggle(enabled) }
                            }

                        if viewModel.syncCalendar && calendarManager.isAuthorized {
                            HStack {
                                Text("Calendar")
                                Spacer()
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.mint)
                                        .frame(width: 10, height: 10)
                                    Text("SoilMate")
                                        .foregroundColor(.secondary)
                                }
                            }

                            if calendarManager.isSyncing {
                                HStack {
                                    Text("Syncing tasks...")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                    }

                    // MARK: - About
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("V1.0.0").foregroundColor(.secondary)
                        }

                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            Text("Privacy")
                        }

                        NavigationLink {
                            TermsOfServiceView()
                        } label: {
                            Text("Terms of Service")
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
                calendarManager.checkAuthorizationStatus()
            }
            .alert("Calendar Access Denied", isPresented: $showCalendarDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    viewModel.syncCalendar = false
                }
            } message: {
                Text("SoilMate needs calendar access to sync care reminders. Please enable it in Settings.")
            }
        }
        .tint(nil)
    }

    // MARK: - Calendar Toggle Handler

    private func handleCalendarToggle(_ enabled: Bool) async {
        if enabled {
            // Request permission
            let granted = await calendarManager.requestAccess()

            if granted {
                // Fetch all pending tasks and sync
                do {
                    let todayTasks = try await CareTaskService.getTodayTasks()
                    let upcomingTasks = try await CareTaskService.getUpcomingTasks()
                    let allTasks = todayTasks + upcomingTasks

                    await calendarManager.syncAllTasks(allTasks, reminderTime: viewModel.reminderTime)
                } catch {
                    print("❌ Failed to fetch tasks for calendar sync: \(error)")
                }
            } else {
                // Permission denied, show alert and revert toggle
                await MainActor.run {
                    showCalendarDenied = true
                }
            }
        } else {
            // Remove all SoilMate events
            calendarManager.removeAllEvents()
        }
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

// MARK: - Privacy Policy View (placeholder)

private struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy content goes here.\nLoad from PRIVACY_POLICY.md")
                .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Terms of Service View (placeholder)

private struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Service content goes here.\nLoad from TERMS_OF_SERVICE.md")
                .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environment(AuthManager())
}
