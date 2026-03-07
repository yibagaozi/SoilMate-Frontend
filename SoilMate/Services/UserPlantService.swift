//
//  UserPlantService.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum UserPlantService {

    private static let client = NetworkClient.shared

    /// Get all plants in the user's garden.
    static func listMyPlants() async throws -> [UserPlantDetail] {
        try await client.get(APIEndpoints.userPlants)
    }

    /// Get full detail for one plant in the garden.
    static func getDetail(id: Int64) async throws -> UserPlantDetail {
        try await client.get(APIEndpoints.userPlant(id: id))
    }

    /// Add a new plant to the garden.
    /// Returns { "id": 123 } — the new user plant ID.
    static func addPlant(_ request: AddUserPlantRequest) async throws -> [String: Int64] {
        try await client.post(APIEndpoints.userPlants, body: request)
    }

    /// Update a plant in the garden (nickname, care schedule, etc.).
    static func updatePlant(id: Int64, _ request: UpdateUserPlantRequest) async throws {
        // Backend returns ApiResponse<null> with message "Plant updated"
        // We use a dummy decode type since we don't need the response body.
        let _: EmptyBody = try await client.patch(APIEndpoints.userPlant(id: id), body: request)
    }

    /// Delete a plant from the garden.
    static func deletePlant(id: Int64) async throws {
        try await client.delete(APIEndpoints.userPlant(id: id))
    }
}

/// Helper type for endpoints that return no data
private struct EmptyBody: Decodable {}
