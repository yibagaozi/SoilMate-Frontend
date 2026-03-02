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

    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?

    // true = 用模拟数据，不调后端
    private let isMock: Bool

    init(isMock: Bool = false) {
        self.isMock = isMock
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        if isMock {
            // 模拟网络延迟
            try? await Task.sleep(for: .seconds(1))

            // 模拟校验：固定密码 12345678 可以登录
            if email.contains("@") && password == "12345678" {
                isLoggedIn = true
            } else {
                errorMessage = "Invalid email or password"
            }
            isLoading = false
            return
        }

        // TODO: 真实登录逻辑
        // let response = try await AuthService.login(...)
        isLoading = false
    }

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

        // TODO: 真实注册逻辑
        isLoading = false
    }

    func logout() {
        isLoggedIn = false
    }
}
