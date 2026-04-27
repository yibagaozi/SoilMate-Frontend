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

    /// Update a plant in the garden (nickname, care schedule, photo, etc.).
    /// Backend returns ApiResponse with `data: null` on success, so we use
    /// patchNoContent to avoid treating that as an error.
    static func updatePlant(id: Int64, _ request: UpdateUserPlantRequest) async throws {
        try await client.patchNoContent(APIEndpoints.userPlant(id: id), body: request)
    }

    /// Delete a plant from the garden.
    static func deletePlant(id: Int64) async throws {
        try await client.delete(APIEndpoints.userPlant(id: id))
    }
}
