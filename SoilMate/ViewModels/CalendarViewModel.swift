//
//  CalendarViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation

@Observable
final class CalendarViewModel {

    // MARK: - State

    /// Currently selected date
    var selectedDate = Date() {
        didSet {
            Task { await loadAll() }
        }
    }

    /// Filter: 0 = All, 1 = Watering, 2 = Feeding
    var selectedFilter = 0

    /// All tasks for the selected date (before filtering)
    private var allTasks: [CareTaskItem] = []

    /// All care logs for the selected date
    private var allLogs: [CareLogItem] = []

    /// Filtered tasks
    var wateringTasks: [CareTaskItem] {
        allTasks.filter { $0.isWatering }
    }

    var feedingTasks: [CareTaskItem] {
        allTasks.filter { !$0.isWatering }
    }

    /// Filtered logs
    var wateringLogs: [CareLogItem] {
        allLogs.filter { $0.isWatering }
    }

    var feedingLogs: [CareLogItem] {
        allLogs.filter { !$0.isWatering }
    }

    /// Check if there are any logs
    var hasLogs: Bool { !allLogs.isEmpty }

    /// Check if there are any tasks
    var hasTasks: Bool { !allTasks.isEmpty }

    var isLoading = false
    var errorMessage: String?

    // MARK: - Load All

    /// Load both tasks and logs for the selected date
    func loadAll() async {
        isLoading = true
        errorMessage = nil

        let dateString = DateHelper.toDateString(selectedDate)

        do {
            async let tasksResult = CareTaskService.getTasksByDate(dateString)
            async let logsResult = CareLogService.getLogsByDate(date: dateString)

            allTasks = try await tasksResult
            allLogs = try await logsResult
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load data"
        }

        isLoading = false
    }

    /// Legacy name kept for compatibility
    func loadTasks() async {
        await loadAll()
    }

    // MARK: - Complete Task

    func completeTask(_ task: CareTaskItem) async -> TaskDetail? {
        let request: CompleteTaskRequest? = task.isWatering
            ? CompleteTaskRequest(
                waterAmountMl: task.displayedWaterAmountMl,
                feedingType: nil,
                notes: nil
            )
            : nil
 
        do {
            let detail = try await CareTaskService.completeTask(id: task.id, request: request)
            allTasks.removeAll { $0.id == task.id }
            updateCalendarEvent(task: task, detail: detail)
            NotificationManager.shared.removeNotification(forTaskId: task.id)
 
            // Reload logs so the new entry shows up
            let dateString = DateHelper.toDateString(selectedDate)
            allLogs = (try? await CareLogService.getLogsByDate(date: dateString)) ?? allLogs
            return detail
        } catch let error as ApiError {
            errorMessage = error.errorDescription
            return nil
        } catch {
            errorMessage = "Failed to complete task"
            return nil
        }
    }
 
    // MARK: - Skip
 
    func skipTask(_ task: CareTaskItem, reason: String? = nil) async -> TaskDetail? {
        let request = reason.map { SkipTaskRequest(reason: $0) }
        do {
            let detail = try await CareTaskService.skipTask(id: task.id, request: request)
            allTasks.removeAll { $0.id == task.id }
            updateCalendarEvent(task: task, detail: detail)
            NotificationManager.shared.removeNotification(forTaskId: task.id)
            return detail
        } catch let error as ApiError {
            errorMessage = error.errorDescription
            return nil
        } catch {
            errorMessage = "Failed to skip task"
            return nil
        }
    }
    
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

    // MARK: - Display Helpers

    /// Task shows the COEFFICIENT-ADJUSTED amount (what should be poured today).
    func taskDetail(_ task: CareTaskItem) -> String {
        task.displayDetail
    }

    /// "200 ml" or "General fertilizer"
    func logDetail(_ log: CareLogItem) -> String {
        if log.isWatering {
            return log.waterAmountMl.map { "\($0) ml" } ?? "Watered"
        } else {
            return log.feedingType ?? "Fed"
        }
    }

    /// Display date for a log: "Apr 20, 2025"
    func logDate(_ log: CareLogItem) -> String {
        guard let dateStr = log.performedAt else { return "—" }
        guard let date = DateHelper.parseDateTime(dateStr) else { return dateStr }
        return DateHelper.displayDate(date)
    }
}
