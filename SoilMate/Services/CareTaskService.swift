//
//  CareTaskService.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum CareTaskService {

    private static let client = NetworkClient.shared

    /// Get today's tasks for the current user.
    static func getTodayTasks() async throws -> [CareTaskItem] {
        try await client.get(APIEndpoints.todayTasks)
    }

    /// Get upcoming tasks (next 7 days or so).
    static func getUpcomingTasks() async throws -> [CareTaskItem] {
        try await client.get(APIEndpoints.upcomingTasks)
    }

    /// Get tasks for a specific date.
    /// - Parameter date: format "yyyy-MM-dd" (e.g. "2025-04-20")
    static func getTasksByDate(_ date: String) async throws -> [CareTaskItem] {
        try await client.get(APIEndpoints.tasksByDate, query: ["date": date])
    }

    /// Mark a task as completed.
    /// - Parameter request: optional override for water amount, feeding type, notes
    static func completeTask(id: Int64, request: CompleteTaskRequest? = nil) async throws -> TaskDetail {
        if let request {
            return try await client.post(APIEndpoints.completeTask(id: id), body: request)
        } else {
            return try await client.post(APIEndpoints.completeTask(id: id))
        }
    }

    /// Skip a task with an optional reason.
    static func skipTask(id: Int64, request: SkipTaskRequest? = nil) async throws -> TaskDetail {
        if let request {
            return try await client.post(APIEndpoints.skipTask(id: id), body: request)
        } else {
            return try await client.post(APIEndpoints.skipTask(id: id))
        }
    }
}
