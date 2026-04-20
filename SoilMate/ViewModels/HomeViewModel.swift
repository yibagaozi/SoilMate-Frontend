//
//  HomeViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation

@Observable
final class HomeViewModel {

    // MARK: - State

    /// The first pending task for today (shown as the big card)
    var todayTask: CareTaskItem?

    /// All today's tasks
    var todayTasks: [CareTaskItem] = []

    /// Upcoming tasks (next few days)
    var upcomingTasks: [CareTaskItem] = []

    var isLoading = false
    var errorMessage: String?
    
    var lastActionResult: TaskActionResult?
    
    struct TaskActionResult: Identifiable {
        let id = UUID()
        let task: CareTaskItem
        let action: TaskActionType
        let detail: TaskDetail?
    }
     
    enum TaskActionType { case completed, skipped }

    // MARK: - Load Data

    /// Call this in .task { } when HomeView appears
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let todayResult = CareTaskService.getTodayTasks()
            async let upcomingResult = CareTaskService.getUpcomingTasks()

            let today = try await todayResult
            let upcoming = try await upcomingResult

            // Build a set of today's IDs to dedupe
            let todayIds = Set(today.map { $0.id })

            todayTasks = today
            // Drop any upcoming task whose ID is already in today
            upcomingTasks = upcoming.filter { !todayIds.contains($0.id) }
            todayTask = todayTasks.first { $0.status == "PENDING" }

            scheduleNotifications()
            syncToWatch()
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load tasks"
        }

        isLoading = false
    }
    // MARK: - Complete Task

    /// Complete a task (e.g. tap the checkmark on today's card)
    func completeTask(_ task: CareTaskItem, actualAmountMl: Int? = nil) async {
        let amountToLog = actualAmountMl ?? task.displayedWaterAmountMl
     
        let request: CompleteTaskRequest? = task.isWatering
            ? CompleteTaskRequest(waterAmountMl: amountToLog, feedingType: nil, notes: nil)
            : nil
     
        do {
            let detail = try await CareTaskService.completeTask(id: task.id, request: request)
     
            todayTasks.removeAll { $0.id == task.id }
            todayTask = todayTasks.first { $0.status == "PENDING" }
            upcomingTasks.removeAll { $0.id == task.id }
     
            updateCalendarEvent(task: task, detail: detail)
            NotificationManager.shared.removeNotification(forTaskId: task.id)
            syncToWatch()
     
            lastActionResult = TaskActionResult(task: task, action: .completed, detail: detail)
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to complete task"
        }
    }
    
    func skipTask(_ task: CareTaskItem, reason: String? = nil) async {
        let request = reason.map { SkipTaskRequest(reason: $0) }
        do {
            let detail = try await CareTaskService.skipTask(id: task.id, request: request)
 
            todayTasks.removeAll { $0.id == task.id }
            todayTask = todayTasks.first { $0.status == "PENDING" }
            upcomingTasks.removeAll { $0.id == task.id }
 
            updateCalendarEvent(task: task, detail: detail)
            NotificationManager.shared.removeNotification(forTaskId: task.id)
            syncToWatch()
 
            lastActionResult = TaskActionResult(task: task, action: .skipped, detail: detail)
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to skip task"
        }
    }

    // MARK: - Helpers
    
    private func updateCalendarEvent(task: CareTaskItem, detail: TaskDetail) {
        let cm = CalendarManager.shared
        cm.removeCareEvent(taskId: task.id)
        if let nextId = detail.nextTaskId, let nextDate = detail.nextTaskDate {
            cm.addCareEvent(
                taskId: nextId,
                plantName: task.plantNickname ?? "Plant",
                careType: task.careType,
                scheduledDate: nextDate
            )
        }
    }
 
    private func scheduleNotifications() {
        let nm = NotificationManager.shared
        guard nm.isAuthorized else { return }
        let defaultTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        nm.scheduleTaskNotifications(tasks: todayTasks, reminderTime: defaultTime)
    }
 
    private func syncToWatch() {
        WatchConnectivityManager.shared.sendTasks(
            today: todayTasks,
            upcoming: upcomingTasks
        )
    }
 
    // MARK: - Watch Action Handler
 
    func handleWatchAction(
        taskId: Int64,
        action: WatchTaskAction,
        reason: String?,
        waterAmountMl: Int?
    ) async {
        guard let task = todayTasks.first(where: { $0.id == taskId })
                ?? upcomingTasks.first(where: { $0.id == taskId })
        else {
            WatchConnectivityManager.shared.sendTaskResult(
                PortableTaskResult(
                    taskId: taskId,
                    success: false,
                    action: action.rawValue,
                    errorMessage: "Task not found"
                )
            )
            return
        }
 
        switch action {
        case .complete:
            // Watch already calculated; prefer its value
            await completeTask(task, actualAmountMl: waterAmountMl)
        case .skip:
            await skipTask(task, reason: reason)
        }
 
        WatchConnectivityManager.shared.sendTaskResult(
            PortableTaskResult(
                taskId: taskId,
                success: errorMessage == nil,
                action: action.rawValue,
                errorMessage: errorMessage
            )
        )
    }

    /// Display text for a task: "200ml · scheduled for 8:00 AM"
    func taskDetailText(_ task: CareTaskItem) -> String {
        if task.isWatering {
            let amount = task.waterAmountMl.map { "\($0)ml" } ?? "Water"
            return "\(amount) · scheduled for today"
        } else {
            let type = task.feedingType ?? "Fertilizer"
            return "\(type) · scheduled for today"
        }
    }

    /// "Tomorrow", "In 3 Days", etc.
    func statusText(_ task: CareTaskItem) -> String {
        DateHelper.relativeDayText(from: task.scheduledDate)
    }
}
