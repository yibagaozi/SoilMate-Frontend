import Foundation
import SwiftUI

@Observable
final class AuthManager {

    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?

    private let isMock: Bool

    init(isMock: Bool = false) {
        self.isMock = isMock
        // Check for saved token on launch
        if !isMock {
            isLoggedIn = KeychainHelper.read(key: KeychainHelper.accessTokenKey) != nil
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        if isMock {
            try? await Task.sleep(for: .seconds(1))
            if email.contains("@") && password == "12345678" {
                isLoggedIn = true
            } else {
                errorMessage = "Invalid email or password"
            }
            isLoading = false
            return
        }

        do {
            let request = LoginRequest(email: email, password: password)
            let auth: AuthResponse = try await NetworkClient.shared.authRequest(
                APIEndpoints.login,
                body: request
            )
            saveTokens(auth.tokens)
            isLoggedIn = true
        } catch ApiError.unauthorized {
            errorMessage = "Invalid email or password"
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Network error. Please try again."
        }

        isLoading = false
    }

    // MARK: - Register

    func register(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil

        if isMock {
            try? await Task.sleep(for: .seconds(1.5))
            if password.count < 8 {
                errorMessage = "Password must be at least 8 characters"
            } else if email.contains("@") {
                isLoggedIn = true
            } else {
                errorMessage = "Invalid email address"
            }
            isLoading = false
            return
        }

        do {
            let request = RegisterRequest(
                email: email,
                password: password,
                displayName: displayName
            )
            let auth: AuthResponse = try await NetworkClient.shared.authRequest(
                APIEndpoints.register,
                body: request
            )
            saveTokens(auth.tokens)
            isLoggedIn = true
        } catch ApiError.conflict {
            errorMessage = "This email is already registered"
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Network error. Please try again."
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() {
        KeychainHelper.delete(key: KeychainHelper.accessTokenKey)
        KeychainHelper.delete(key: KeychainHelper.refreshTokenKey)
        isLoggedIn = false
    }

    // MARK: - Token Storage

    private func saveTokens(_ tokens: TokenResponse) {
        KeychainHelper.save(key: KeychainHelper.accessTokenKey, value: tokens.accessToken)
        KeychainHelper.save(key: KeychainHelper.refreshTokenKey, value: tokens.refreshToken)
    }
}
