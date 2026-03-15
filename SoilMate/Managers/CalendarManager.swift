//
//  CalendarManager.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/15.
//
import Foundation
import EventKit
import SwiftUI

@Observable
final class CalendarManager {

    static let shared = CalendarManager()

    // MARK: - State

    var isAuthorized = false
    var isSyncing = false

    // MARK: - Private

    private let store = EKEventStore()
    private let calendarName = "SoilMate"
    private let calendarColor = CGColor(red: 0.24, green: 0.81, blue: 0.65, alpha: 1) // mint

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Check current authorization status without prompting
    func checkAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = (status == .fullAccess || status == .writeOnly)
    }

    /// Request write-only access to calendar (iOS 17+)
    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestWriteOnlyAccessToEvents()
            await MainActor.run { isAuthorized = granted }
            return granted
        } catch {
            print("Calendar access denied: \(error)")
            await MainActor.run { isAuthorized = false }
            return false
        }
    }

    // MARK: - SoilMate Calendar

    /// Find or create the dedicated SoilMate calendar
    private func soilMateCalendar() -> EKCalendar? {
        // Look for existing calendar
        if let existing = store.calendars(for: .event).first(where: { $0.title == calendarName }) {
            return existing
        }

        // Create new calendar
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = calendarName
        calendar.cgColor = calendarColor

        // Use default calendar source
        if let source = store.defaultCalendarForNewEvents?.source {
            calendar.source = source
        } else if let source = store.sources.first(where: { $0.sourceType == .local }) {
            calendar.source = source
        } else {
            print("No calendar source available")
            return nil
        }

        do {
            try store.saveCalendar(calendar, commit: true)
            return calendar
        } catch {
            print("Failed to create SoilMate calendar: \(error)")
            return nil
        }
    }

    // MARK: - Add Event

    /// Add a care task as a calendar event
    /// - Parameters:
    ///   - taskId: The CareTask ID (stored in event notes for later lookup)
    ///   - plantName: Display name of the plant
    ///   - careType: "WATER" or "FEED"
    ///   - scheduledDate: The date the task is due
    ///   - reminderTime: Time of day for the event (from user settings)
    ///   - detail: Additional info like "200ml" or "General fertilizer"
    func addCareEvent(
        taskId: Int64,
        plantName: String,
        careType: String,
        scheduledDate: String,
        reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        detail: String? = nil
    ) {
        guard isAuthorized, let calendar = soilMateCalendar() else { return }

        // Parse scheduled date
        guard let date = DateHelper.parseDate(scheduledDate) else { return }

        // Build event time from date + reminder time
        let timeComponents = Foundation.Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        var eventComponents = Foundation.Calendar.current.dateComponents([.year, .month, .day], from: date)
        eventComponents.hour = timeComponents.hour
        eventComponents.minute = timeComponents.minute

        guard let eventDate = Foundation.Calendar.current.date(from: eventComponents) else { return }

        // Build title
        let typeLabel = careType == "WATER" ? "Water" : "Feed"

        let event = EKEvent(eventStore: store)
        event.title = "\(typeLabel) \(plantName)"
        event.startDate = eventDate
        event.endDate = eventDate.addingTimeInterval(15 * 60) // 15 min duration
        event.calendar = calendar
        event.notes = "SoilMate Task ID: \(taskId)"

        if let detail {
            event.notes = (event.notes ?? "") + "\n\(detail)"
        }

        // Add 30-minute reminder
        event.addAlarm(EKAlarm(relativeOffset: -30 * 60))

        do {
            try store.save(event, span: .thisEvent)
        } catch {
            print("Failed to save calendar event: \(error)")
        }
    }

    // MARK: - Remove Event

    /// Remove calendar event for a specific task ID
    func removeCareEvent(taskId: Int64) {
        guard isAuthorized else { return }

        let calendars = store.calendars(for: .event).filter { $0.title == calendarName }
        guard !calendars.isEmpty else { return }

        // Search events in the next year
        let start = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days ago
        let end = Date().addingTimeInterval(365 * 24 * 60 * 60)   // 1 year ahead
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)

        let events = store.events(matching: predicate)
        let targetNote = "SoilMate Task ID: \(taskId)"

        for event in events where event.notes?.contains(targetNote) == true {
            do {
                try store.remove(event, span: .thisEvent)
            } catch {
                print("Failed to remove calendar event: \(error)")
            }
        }
    }

    // MARK: - Sync All Tasks

    /// Sync all pending tasks to calendar (called when user enables sync)
    func syncAllTasks(_ tasks: [CareTaskItem], reminderTime: Date) async {
        guard isAuthorized else { return }

        await MainActor.run { isSyncing = true }

        for task in tasks {
            let detail: String? = task.isWatering
                ? task.waterAmountMl.map { "\($0)ml" }
                : task.feedingType

            addCareEvent(
                taskId: task.id,
                plantName: task.plantNickname ?? "Plant",
                careType: task.careType,
                scheduledDate: task.scheduledDate,
                reminderTime: reminderTime,
                detail: detail
            )
        }

        await MainActor.run { isSyncing = false }
    }

    // MARK: - Remove All Events

    /// Remove the entire SoilMate calendar (called when user disables sync)
    func removeAllEvents() {
        guard let calendar = store.calendars(for: .event).first(where: { $0.title == calendarName }) else {
            return
        }

        do {
            try store.removeCalendar(calendar, commit: true)
        } catch {
            print("Failed to remove SoilMate calendar: \(error)")
        }
    }

    // MARK: - Remove Events for a Plant

    /// Remove all calendar events for a specific plant (called when deleting a plant)
    func removeEventsForPlant(plantName: String) {
        guard isAuthorized else { return }

        let calendars = store.calendars(for: .event).filter { $0.title == calendarName }
        guard !calendars.isEmpty else { return }

        let start = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        let end = Date().addingTimeInterval(365 * 24 * 60 * 60)
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)

        let events = store.events(matching: predicate)
        for event in events where event.title?.contains(plantName) == true {
            do {
                try store.remove(event, span: .thisEvent)
            } catch {
                print("Failed to remove event for plant \(plantName): \(error)")
            }
        }
    }
}
