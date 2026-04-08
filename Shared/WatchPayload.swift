//
//  WatchPayload.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import Foundation
 
// MARK: - Message Keys
 
enum WatchMessageKey {
    static let type = "type"
    static let taskId = "taskId"
    static let action = "action"
    static let reason = "reason"
    static let waterAmountMl = "waterAmountMl"
    static let detail = "detail"
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
}
 
// MARK: - Message Types
 
enum WatchMessageType: String {
    case syncTasks
    case taskAction
    case taskResult
    case syncTokens
    case requestSync
}
 
// MARK: - Task Action
 
enum WatchTaskAction: String, Codable {
    case complete
    case skip
}
 
// MARK: - Portable Task
 
/// Display-ready task snapshot. waterAmountMl is already adjusted.
struct PortableTask: Codable, Identifiable {
    let id: Int64
    let careType: String            // "WATER" or "FEED"
    let scheduledDate: String
    let status: String
    let daysUntil: Int?
    /// Adjusted amount (coefficients already applied on iOS).
    /// This is what the watch displays and sends back on completion.
    let waterAmountMl: Int?
    let feedingType: String?
    let plantNickname: String?
    let plantLocation: String?
 
    var isWatering: Bool { careType == "WATER" }
 
    var careTypeDisplay: String {
        isWatering ? "Watering" : "Feeding"
    }
 
    var detailText: String {
        if isWatering {
            return waterAmountMl.map { "\($0)ml" } ?? "Water"
        } else {
            return feedingType ?? "Fertilizer"
        }
    }
}
 
// MARK: - Task Result
 
struct PortableTaskResult: Codable {
    let taskId: Int64
    let success: Bool
    let action: String
    let errorMessage: String?
}
 
// MARK: - Encoding
 
enum WatchPayloadEncoder {
 
    static func encodeSyncTasks(
        today: [PortableTask],
        upcoming: [PortableTask]
    ) -> [String: Any] {
        let encoder = JSONEncoder()
        let todayData = (try? encoder.encode(today)) ?? Data()
        let upcomingData = (try? encoder.encode(upcoming)) ?? Data()
 
        return [
            WatchMessageKey.type: WatchMessageType.syncTasks.rawValue,
            "todayTasks": todayData,
            "upcomingTasks": upcomingData
        ]
    }
 
    static func encodeTaskAction(
        taskId: Int64,
        action: WatchTaskAction,
        reason: String? = nil,
        waterAmountMl: Int? = nil
    ) -> [String: Any] {
        var msg: [String: Any] = [
            WatchMessageKey.type: WatchMessageType.taskAction.rawValue,
            WatchMessageKey.taskId: taskId,
            WatchMessageKey.action: action.rawValue
        ]
        if let reason { msg[WatchMessageKey.reason] = reason }
        if let waterAmountMl { msg[WatchMessageKey.waterAmountMl] = waterAmountMl }
        return msg
    }
 
    static func encodeTaskResult(_ result: PortableTaskResult) -> [String: Any] {
        let data = (try? JSONEncoder().encode(result)) ?? Data()
        return [
            WatchMessageKey.type: WatchMessageType.taskResult.rawValue,
            WatchMessageKey.detail: data
        ]
    }
 
    static func encodeTokens(access: String, refresh: String) -> [String: Any] {
        return [
            WatchMessageKey.type: WatchMessageType.syncTokens.rawValue,
            WatchMessageKey.accessToken: access,
            WatchMessageKey.refreshToken: refresh
        ]
    }
}
 
// MARK: - Decoding
 
enum WatchPayloadDecoder {
 
    static func messageType(from message: [String: Any]) -> WatchMessageType? {
        guard let raw = message[WatchMessageKey.type] as? String else { return nil }
        return WatchMessageType(rawValue: raw)
    }
 
    static func decodeTasks(
        from message: [String: Any]
    ) -> (today: [PortableTask], upcoming: [PortableTask]) {
        let decoder = JSONDecoder()
        var today: [PortableTask] = []
        var upcoming: [PortableTask] = []
 
        if let data = message["todayTasks"] as? Data {
            today = (try? decoder.decode([PortableTask].self, from: data)) ?? []
        }
        if let data = message["upcomingTasks"] as? Data {
            upcoming = (try? decoder.decode([PortableTask].self, from: data)) ?? []
        }
 
        return (today, upcoming)
    }
 
    static func decodeTaskAction(
        from message: [String: Any]
    ) -> (taskId: Int64, action: WatchTaskAction, reason: String?, waterAmountMl: Int?)? {
        guard let taskId = message[WatchMessageKey.taskId] as? Int64,
              let actionRaw = message[WatchMessageKey.action] as? String,
              let action = WatchTaskAction(rawValue: actionRaw)
        else { return nil }
 
        return (
            taskId,
            action,
            message[WatchMessageKey.reason] as? String,
            message[WatchMessageKey.waterAmountMl] as? Int
        )
    }
 
    static func decodeTaskResult(from message: [String: Any]) -> PortableTaskResult? {
        guard let data = message[WatchMessageKey.detail] as? Data else { return nil }
        return try? JSONDecoder().decode(PortableTaskResult.self, from: data)
    }
}
