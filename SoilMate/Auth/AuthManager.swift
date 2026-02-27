//
//  AuthManager.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation
import SwiftUI

@Observable
final class AuthManager {

    // MARK: - Published State

    /// true when user is logged in (has valid tokens)
    var isLoggedIn: Bool = false

    /// Current user info (set after login/register)
    var currentUser: UserResponse?

    /// Error message to show in UI
    var errorMessage: String?

    /// true while a login/register request is in progress
    var isLoading: Bool = false

    // MARK: - Init

    init() {
        // Check if we have a saved token on app launch
        if KeychainHelper.read(key: KeychainHelper.accessTokenKey) != nil {
            isLoggedIn = true
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let body = LoginRequest(email: email, password: password)
            let response: AuthResponse = try await NetworkClient.shared.authRequest(
                APIEndpoints.login,
                body: body
            )

            saveTokens(response.tokens)
            currentUser = response.user
            isLoggedIn = true
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Login failed"
        }

        isLoading = false
    }

    // MARK: - Register

    func register(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let body = RegisterRequest(
                email: email,
                password: password,
                displayName: displayName
            )
            let response: AuthResponse = try await NetworkClient.shared.authRequest(
                APIEndpoints.register,
                body: body
            )

            saveTokens(response.tokens)
            currentUser = response.user
            isLoggedIn = true
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Registration failed"
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() {
        KeychainHelper.delete(key: KeychainHelper.accessTokenKey)
        KeychainHelper.delete(key: KeychainHelper.refreshTokenKey)
        currentUser = nil
        isLoggedIn = false
    }

    // MARK: - Helpers

    private func saveTokens(_ tokens: TokenResponse) {
        KeychainHelper.save(key: KeychainHelper.accessTokenKey, value: tokens.accessToken)
        KeychainHelper.save(key: KeychainHelper.refreshTokenKey, value: tokens.refreshToken)
    }
}
