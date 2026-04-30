//
//  NotificationManager.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/8.
//

import Foundation
import UserNotifications
 
@Observable
final class NotificationManager {
 
    static let shared = NotificationManager()
 
    // MARK: - State
 
    var isAuthorized = false
 
    private let center = UNUserNotificationCenter.current()
 
    private init() {
        checkAuthorizationStatus()
    }
 
    // MARK: - Authorization
 
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
 
    /// Request notification permission. Call at app launch.
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run { isAuthorized = granted }
            return granted
        } catch {
            print("[Notifications] Authorization request failed: \(error.localizedDescription)")
            await MainActor.run { isAuthorized = false }
            return false
        }
    }
 
    // MARK: - Schedule Notifications for Today's Tasks
 
    /// Schedule one notification per pending task.
    /// Removes previously scheduled SoilMate notifications first.
    /// - Parameters:
    ///   - tasks: today's pending care tasks
    ///   - reminderTime: the user's preferred reminder time
    func scheduleTaskNotifications(
        tasks: [CareTaskItem],
        reminderTime: Date
    ) {
        guard isAuthorized else { return }
 
        // Remove all existing SoilMate task notifications
        removeAllTaskNotifications()
 
        let pendingTasks = tasks.filter { $0.status == "PENDING" }
        guard !pendingTasks.isEmpty else { return }
 
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
 
        for (index, task) in pendingTasks.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = buildTitle(for: task)
            content.body = buildBody(for: task)
            content.sound = .default
            content.categoryIdentifier = "CARE_TASK"
            content.userInfo = [
                "taskId": task.id,
                "careType": task.careType,
                "userPlantId": task.userPlantId
            ]
 
            // Schedule at reminder time, offset by a few seconds per task
            // so they don't all fire at the exact same instant
            var dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: Date()
            )
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            dateComponents.second = index * 2  // stagger slightly
 
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
 
            let identifier = notificationId(for: task.id)
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
 
            center.add(request) { error in
                if let error {
                    print("[Notifications] Failed to schedule for task \(task.id): \(error.localizedDescription)")
                }
            }
        }
    }
 
    // MARK: - Remove Notification for a Completed/Skipped Task
 
    /// Call this when a task is completed or skipped so the reminder is cancelled.
    func removeNotification(forTaskId taskId: Int64) {
        let identifier = notificationId(for: taskId)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
 
    // MARK: - Remove All Task Notifications
 
    func removeAllTaskNotifications() {
        center.getPendingNotificationRequests { [weak self] requests in
            let soilmateIds = requests
                .filter { $0.identifier.hasPrefix("soilmate_task_") }
                .map { $0.identifier }
            self?.center.removePendingNotificationRequests(withIdentifiers: soilmateIds)
        }
 
        center.getDeliveredNotifications { [weak self] notifications in
            let soilmateIds = notifications
                .filter { $0.request.identifier.hasPrefix("soilmate_task_") }
                .map { $0.request.identifier }
            self?.center.removeDeliveredNotifications(withIdentifiers: soilmateIds)
        }
    }
 
    // MARK: - Notification ID
 
    private func notificationId(for taskId: Int64) -> String {
        "soilmate_task_\(taskId)"
    }
 
    // MARK: - Content Builders (lively tone, no emoji)
 
    private func buildTitle(for task: CareTaskItem) -> String {
        let name = task.plantNickname ?? "Your plant"
 
        if task.isWatering {
            return titleVariantsWatering.randomElement()!
                .replacingOccurrences(of: "{name}", with: name)
        } else {
            return titleVariantsFeeding.randomElement()!
                .replacingOccurrences(of: "{name}", with: name)
        }
    }
 
    private func buildBody(for task: CareTaskItem) -> String {
        let name = task.plantNickname ?? "Your plant"
        let location = task.plantLocation.map { " in the \($0)" } ?? ""
 
        if task.isWatering {
            let amount = task.waterAmountMl.map { "\($0)ml" } ?? "a good drink"
            return bodyVariantsWatering.randomElement()!
                .replacingOccurrences(of: "{name}", with: name)
                .replacingOccurrences(of: "{amount}", with: amount)
                .replacingOccurrences(of: "{location}", with: location)
        } else {
            let type = task.feedingType ?? "some fertilizer"
            return bodyVariantsFeeding.randomElement()!
                .replacingOccurrences(of: "{name}", with: name)
                .replacingOccurrences(of: "{type}", with: type)
                .replacingOccurrences(of: "{location}", with: location)
        }
    }
 
    // MARK: - Copy Variants
 
    private let titleVariantsWatering = [
        "{name} is thirsty today",
        "Time to water {name}",
        "{name} could use a drink",
        "Watering day for {name}",
        "Don't forget {name}"
    ]
 
    private let titleVariantsFeeding = [
        "{name} is hungry today",
        "Feeding time for {name}",
        "{name} needs some nutrients",
        "Time to feed {name}",
        "Nourish {name} today"
    ]
 
    private let bodyVariantsWatering = [
        "{name}{location} is ready for {amount} of water. A little care goes a long way.",
        "Give {name}{location} about {amount} of water today. Your plant will thank you.",
        "Your {name}{location} needs watering -- {amount} should do the trick.",
        "{amount} of water for {name}{location} and you are all set for the day."
    ]
 
    private let bodyVariantsFeeding = [
        "{name}{location} would love some {type} today. A well-fed plant is a happy plant.",
        "Time to give {name}{location} a boost with {type}. Dinner is served.",
        "Your {name}{location} is due for {type}. Keep those leaves looking their best.",
        "Feed {name}{location} with {type} today. Growing strong takes good nutrition."
    ]
 
    // MARK: - Register Notification Categories (for actionable notifications)
 
    func registerCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Done",
            options: [.foreground]
        )
 
        let skipAction = UNNotificationAction(
            identifier: "SKIP_TASK",
            title: "Skip",
            options: []
        )
 
        let category = UNNotificationCategory(
            identifier: "CARE_TASK",
            actions: [completeAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
 
        center.setNotificationCategories([category])
    }
}
 
