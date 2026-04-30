//
//  KeychainHelper.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation
import Security

enum KeychainHelper {

    // Save a string to Keychain
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete old value first (Keychain does not allow duplicate keys)
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    // Read a string from Keychain. Returns nil if not found.
    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return string
    }

    // Delete a value from Keychain
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Key Names

extension KeychainHelper {
    static let accessTokenKey  = "soilmate_access_token"
    static let refreshTokenKey = "soilmate_refresh_token"
}
