//
//  SettingsViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation

@Observable
final class SettingsViewModel {

    // MARK: - Profile State

    var displayName = ""
    var email = ""
    var avatarUrl: String?
    var timezone = "UTC"

    // MARK: - Settings State

    var notificationEnabled = true

    /// Defaults to 9:00 AM. Using a fixed reference time prevents the
    /// picker from briefly showing the current launch time before the
    /// server value loads.
    var reminderTime: Date = SettingsViewModel.defaultReminderTime

    /// Sync with iOS calendar (local only, not sent to backend)
    var syncCalendar = true

    // Region for watering calculation
    var region: Region = WateringCalculator.currentRegion

    /// Notification sound (local only)
    var sound = "Default"

    // MARK: - Loading State

    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var successMessage: String?

    /// True after the initial profile load completes. The view uses this
    /// to suppress auto-save callbacks that would otherwise fire when
    /// fillFrom() updates fields from the server response.
    var hasLoaded = false

    // MARK: - Default

    private static var defaultReminderTime: Date {
        var c = DateComponents()
        c.hour = 9
        c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }

    // MARK: - Load Profile

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let profile = try await UserService.getMyProfile()
            fillFrom(profile)
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load profile"
        }

        isLoading = false

        // Let SwiftUI flush any .onChange callbacks triggered by fillFrom
        // before we mark the model as loaded. Those callbacks will see
        // hasLoaded = false and skip the auto-save. Anything the user
        // changes after this delay is treated as a real edit.
        try? await Task.sleep(for: .milliseconds(150))
        hasLoaded = true
    }

    // MARK: - Save Settings

    func saveSettings() async {
        isSaving = true
        errorMessage = nil
        successMessage = nil

        // Format reminder time as "HH:mm" using a fixed locale so that
        // 24-hour formatting works consistently across regions.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: reminderTime)

        let request = UpdateUserRequest(
            displayName: displayName,
            timezone: timezone,
            notificationEnabled: notificationEnabled,
            reminderTime: timeString,
            region: region.rawValue
        )

        do {
            _ = try await UserService.updateProfile(request)
            successMessage = "Settings saved"
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to save settings"
        }

        isSaving = false
    }

    // MARK: - Region

    /// Called when the user picks a region from the list.
    func setRegion(_ newRegion: Region) {
        region = newRegion
        WateringCalculator.currentRegion = newRegion
        Task {
            await saveSettings()
            // After region change, refresh watch tasks so calculated
            // amounts match the new seasonal factors.
            await refreshWatchTasks()
        }
    }

    /// Recalculate and re-push tasks to the watch after a region change.
    private func refreshWatchTasks() async {
        do {
            async let today = CareTaskService.getTodayTasks()
            async let upcoming = CareTaskService.getUpcomingTasks()
            WatchConnectivityManager.shared.sendTasks(
                today: try await today,
                upcoming: try await upcoming
            )
        } catch {
            print("[Settings] Failed to refresh watch tasks: \(error)")
        }
    }

    // MARK: - Fill from Profile

    private func fillFrom(_ profile: UserProfile) {
        displayName = profile.displayName
        email = profile.email
        avatarUrl = profile.avatarUrl
        timezone = profile.timezone
        notificationEnabled = profile.notificationEnabled

        // Parse reminder time. Tolerant of trailing seconds, millis, and
        // anything else by taking only the first 5 characters ("HH:mm").
        if let timeStr = profile.reminderTime, timeStr.count >= 5 {
            let trimmed = String(timeStr.prefix(5))
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            if let date = formatter.date(from: trimmed) {
                reminderTime = date
            }
        }

        // Region: prefer server value, fall back to timezone auto-detect
        if let regionString = profile.region,
            let serverRegion = Region(rawValue: regionString) {
            region = serverRegion
        } else {
            region = WateringCalculator.autoDetectRegion()
        }
        WateringCalculator.currentRegion = region
    }
}
