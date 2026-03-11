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
            // Reload tasks when user picks a new date
            Task { await loadTasks() }
        }
    }

    /// Filter: 0 = All, 1 = Watering, 2 = Feeding
    var selectedFilter = 0

    /// All tasks for the selected date (before filtering)
    private var allTasks: [CareTaskItem] = []

    /// Tasks after applying the filter
    var wateringTasks: [CareTaskItem] {
        allTasks.filter { $0.isWatering }
    }

    var feedingTasks: [CareTaskItem] {
        allTasks.filter { !$0.isWatering }
    }

    var isLoading = false
    var errorMessage: String?

    // MARK: - Load Tasks

    /// Fetch tasks for the selected date
    func loadTasks() async {
        isLoading = true
        errorMessage = nil

        let dateString = DateHelper.toDateString(selectedDate)

        do {
            allTasks = try await CareTaskService.getTasksByDate(dateString)
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load tasks"
        }

        isLoading = false
    }

    // MARK: - Complete Task

    /// Mark a task as done
    func completeTask(_ task: CareTaskItem) async -> TaskDetail? {
        do {
            let detail = try await CareTaskService.completeTask(id: task.id)
            // Remove from list
            allTasks.removeAll { $0.id == task.id }
            return detail
        } catch let error as ApiError {
            errorMessage = error.errorDescription
            return nil
        } catch {
            errorMessage = "Failed to complete task"
            return nil
        }
    }

    // MARK: - Skip Task

    /// Skip a task with optional reason
    func skipTask(_ task: CareTaskItem, reason: String? = nil) async -> TaskDetail? {
        let request = reason.map { SkipTaskRequest(reason: $0) }
        do {
            let detail = try await CareTaskService.skipTask(id: task.id, request: request)
            allTasks.removeAll { $0.id == task.id }
            return detail
        } catch let error as ApiError {
            errorMessage = error.errorDescription
            return nil
        } catch {
            errorMessage = "Failed to skip task"
            return nil
        }
    }

    // MARK: - Helpers

    /// "200ml" or "General fertilizer"
    func taskDetail(_ task: CareTaskItem) -> String {
        if task.isWatering {
            return task.waterAmountMl.map { "\($0)ml" } ?? "Water"
        } else {
            return task.feedingType ?? "Fertilizer"
        }
    }
}
