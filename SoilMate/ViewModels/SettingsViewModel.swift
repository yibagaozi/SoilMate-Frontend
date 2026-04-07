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
    var reminderTime = Date()  // displayed as time picker

    /// Sync with iOS calendar (local only, not sent to backend)
    var syncCalendar = true
    
    // Region for watering calculation
    var region: Region = WateringCalculator.currentRegion

    /// Notification sound (local only)
    var sound = "Default"

    // MARK: - State

    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var successMessage: String?

    // MARK: - Load Profile

    /// Call this in .task { } when SettingsView appears
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
    }

    // MARK: - Save Settings

    /// Save changed settings to the server.
    /// Call this when user toggles notification, changes time, etc.
    func saveSettings() async {
        isSaving = true
        errorMessage = nil
        successMessage = nil

        // Format reminder time as "HH:mm"
        let formatter = DateFormatter()
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
            let updated = try await UserService.updateProfile(request)
            fillFrom(updated)
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

        // Parse "HH:mm:ss" or "HH:mm" into a Date for the time picker
        if let timeStr = profile.reminderTime {
            let formatter = DateFormatter()
            formatter.dateFormat = timeStr.count > 5 ? "HH:mm:ss" : "HH:mm"
            if let date = formatter.date(from: timeStr) {
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
