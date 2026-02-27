//
//  UserModels.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

// MARK: - Response

struct UserProfile: Decodable {
    let id: Int64
    let email: String
    let displayName: String
    let avatarUrl: String?
    let timezone: String
    let notificationEnabled: Bool
    let reminderTime: String?     // "HH:mm"
    let createdAt: String?
    let updatedAt: String?
    let authMethods: [AuthMethod]?
    let stats: UserStats?
}

struct AuthMethod: Decodable {
    let provider: String       // "EMAIL", "GOOGLE", "APPLE"
    let email: String?
    let isPrimary: Bool?
}

struct UserStats: Decodable {
    let totalPlants: Int?
    let activePlants: Int?
}

// MARK: - Request

/// Only send fields that changed. nil fields are ignored by backend.
struct UpdateUserRequest: Encodable {
    var displayName: String?
    var timezone: String?
    var notificationEnabled: Bool?
    var reminderTime: String?  // "HH:mm"
}
