//
//  CareModels.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

// MARK: - Care Task (upcoming reminders)

/// A scheduled care task. Matches CareTaskItemResponse.
struct CareTaskItem: Decodable, Identifiable {
    let id: Int64
    let careType: String        // "WATERING" or "FEEDING"
    let scheduledDate: String   // "2025-04-20"
    let status: String          // "PENDING", "COMPLETED", "SKIPPED"
    let daysUntil: Int?
    let waterAmountMl: Int?
    let feedingType: String?
    let userPlantId: Int64
    let plantNickname: String?
    let plantImageUrl: String?
    let plantLocation: String?

    /// true if this is a watering task
    var isWatering: Bool { careType == "WATER" }
    var careTypeDisplay: String { isWatering ? "Watering" : "Feeding" }
}

/// Full detail after completing or skipping a task. Matches TaskDetailResponse.
struct TaskDetail: Decodable {
    let id: Int64
    let careType: String
    let scheduledDate: String
    let waterAmountMl: Int?
    let feedingType: String?
    let status: String
    let completedAt: String?
    let skipReason: String?
    let nextTaskId: Int64?
    let nextTaskDate: String?
}

// MARK: - Care Log (history records)

/// One care activity record. Matches CareLogItemResponse.
struct CareLogItem: Decodable, Identifiable {
    let id: Int64
    let taskId: Int64?
    let careType: String        // "WATERING" or "FEEDING"
    let performedAt: String?
    let waterAmountMl: Int?
    let feedingType: String?
    let notes: String?
    let userPlantId: Int64?
    let plantNickname: String?
    let plantImageUrl: String?
    let plantLocation: String?
    let photoUrl: String?

    var isWatering: Bool { careType == "WATER" }
    var careTypeDisplay: String { isWatering ? "Watering" : "Feeding" }
}

// MARK: - Requests

/// Complete a care task
struct CompleteTaskRequest: Encodable {
    var waterAmountMl: Int?
    var feedingType: String?
    var notes: String?
}

/// Skip a care task with a reason
struct SkipTaskRequest: Encodable {
    var reason: String?
}

/// Manually add a care log entry
struct AddCareLogRequest: Encodable {
    let userPlantId: Int64
    let careType: String         // "WATERING" or "FEEDING"
    var performedAt: String?     // ISO datetime, nil = now
    var waterAmountMl: Int?
    var feedingType: String?
    var notes: String?
}
