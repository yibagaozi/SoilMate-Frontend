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

    // MARK: - Load Data

    /// Call this in .task { } when HomeView appears
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch today and upcoming at the same time
            async let todayResult = CareTaskService.getTodayTasks()
            async let upcomingResult = CareTaskService.getUpcomingTasks()

            let today = try await todayResult
            let upcoming = try await upcomingResult

            self.todayTasks = today
            self.todayTask = today.first { $0.status == "PENDING" }
            self.upcomingTasks = upcoming
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load tasks"
        }

        isLoading = false
    }

    // MARK: - Complete Task

    /// Complete a task (e.g. tap the checkmark on today's card)
    func completeTask(_ task: CareTaskItem) async {
        do {
            let detail = try await CareTaskService.completeTask(id: task.id)

            // Remove from today list and pick next one
            todayTasks.removeAll { $0.id == task.id }
            todayTask = todayTasks.first { $0.status == "PENDING" }

            // Also remove from upcoming if it was there
            upcomingTasks.removeAll { $0.id == task.id }

            // Update calendar: remove old event, add next one
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
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to complete task"
        }
    }

    // MARK: - Helpers

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
