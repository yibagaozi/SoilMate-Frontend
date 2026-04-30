//
//  CareLogService.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum CareLogService {

    private static let client = NetworkClient.shared

    /// Get care logs for a date. Optionally filter by one plant.
    /// - Parameters:
    ///   - date: format "yyyy-MM-dd"
    ///   - userPlantId: if set, only show logs for this plant
    static func getLogsByDate(
        date: String,
        userPlantId: Int64? = nil
    ) async throws -> [CareLogItem] {
        var query: [String: String] = ["date": date]
        if let userPlantId {
            query["userPlantId"] = String(userPlantId)
        }
        return try await client.get(APIEndpoints.careLogs, query: query)
    }

    /// Add a care log manually (not from completing a task).
    /// Use this when the user logs a past watering or feeding.
    static func addCareLog(_ request: AddCareLogRequest) async throws -> CareLogItem {
        try await client.post(APIEndpoints.careLogs, body: request)
    }
}
