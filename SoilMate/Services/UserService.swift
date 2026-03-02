//
//  UserService.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum UserService {

    private static let client = NetworkClient.shared

    /// Get current user's full profile (includes auth methods + stats).
    static func getMyProfile() async throws -> UserProfile {
        try await client.get(APIEndpoints.myProfile)
    }

    /// Update profile fields. Only send the fields you want to change.
    /// Example: UserService.updateProfile(UpdateUserRequest(displayName: "New Name"))
    static func updateProfile(_ request: UpdateUserRequest) async throws -> UserProfile {
        try await client.patch(APIEndpoints.myProfile, body: request)
    }
}
