//
//  AuthModels.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

// MARK: - Requests

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let displayName: String
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

// MARK: - Responses

/// Returned by login and register
struct AuthResponse: Decodable {
    let user: UserResponse
    let tokens: TokenResponse
}

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int?  // seconds until access token expires
}

/// Basic user info returned after login/register
struct UserResponse: Decodable {
    let id: Int64
    let email: String
    let displayName: String
    let avatarUrl: String?
    let timezone: String?
    let notificationEnabled: Bool?
    let reminderTime: String?  // "HH:mm" format from backend
    let createdAt: String?
}
