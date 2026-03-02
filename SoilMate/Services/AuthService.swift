//
//  AuthService.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum AuthService {

    private static let client = NetworkClient.shared

    /// Login with email and password. Returns user + tokens.
    static func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        return try await client.authRequest(APIEndpoints.login, body: body)
    }

    /// Register a new account. Returns user + tokens.
    static func register(email: String, password: String, displayName: String) async throws -> AuthResponse {
        let body = RegisterRequest(email: email, password: password, displayName: displayName)
        return try await client.authRequest(APIEndpoints.register, body: body)
    }

    /// Refresh access token using refresh token. Returns new tokens.
    static func refresh(refreshToken: String) async throws -> TokenResponse {
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        return try await client.authRequest(APIEndpoints.refresh, body: body)
    }
}
