//
//  KeyChainHelperTests.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/23.
//

import XCTest
@testable import SoilMate

final class KeychainHelperTests: XCTestCase {

    // Use a unique prefix so tests don't collide with real app data
    private let testKey = "soilmate_test_key_\(UUID().uuidString.prefix(8))"
    private let testKey2 = "soilmate_test_key2_\(UUID().uuidString.prefix(8))"

    override func tearDown() {
        // Clean up any test keys
        KeychainHelper.delete(key: testKey)
        KeychainHelper.delete(key: testKey2)
        super.tearDown()
    }

    // MARK: - Save & Read

    func testSaveAndRead_basicString() {
        KeychainHelper.save(key: testKey, value: "hello_world")
        let result = KeychainHelper.read(key: testKey)
        XCTAssertEqual(result, "hello_world")
    }

    func testSaveAndRead_tokenLikeString() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"
        KeychainHelper.save(key: testKey, value: token)
        let result = KeychainHelper.read(key: testKey)
        XCTAssertEqual(result, token)
    }

    func testSaveAndRead_emptyString() {
        KeychainHelper.save(key: testKey, value: "")
        let result = KeychainHelper.read(key: testKey)
        XCTAssertEqual(result, "")
    }

    func testSaveAndRead_unicodeString() {
        KeychainHelper.save(key: testKey, value: "こんにちは🌱")
        let result = KeychainHelper.read(key: testKey)
        XCTAssertEqual(result, "こんにちは🌱")
    }

    // MARK: - Overwrite

    func testSave_overwritesExistingValue() {
        KeychainHelper.save(key: testKey, value: "first_value")
        KeychainHelper.save(key: testKey, value: "second_value")

        let result = KeychainHelper.read(key: testKey)
        XCTAssertEqual(result, "second_value")
    }

    // MARK: - Read Non-existent

    func testRead_nonExistentKey_returnsNil() {
        let result = KeychainHelper.read(key: "key_that_does_not_exist_\(UUID().uuidString)")
        XCTAssertNil(result)
    }

    // MARK: - Delete

    func testDelete_removesValue() {
        KeychainHelper.save(key: testKey, value: "to_be_deleted")
        XCTAssertNotNil(KeychainHelper.read(key: testKey))

        KeychainHelper.delete(key: testKey)
        XCTAssertNil(KeychainHelper.read(key: testKey))
    }

    func testDelete_nonExistentKey_doesNotCrash() {
        // Should simply no-op
        KeychainHelper.delete(key: "nonexistent_\(UUID().uuidString)")
    }

    // MARK: - Multiple Keys

    func testMultipleKeys_independent() {
        KeychainHelper.save(key: testKey, value: "value_a")
        KeychainHelper.save(key: testKey2, value: "value_b")

        XCTAssertEqual(KeychainHelper.read(key: testKey), "value_a")
        XCTAssertEqual(KeychainHelper.read(key: testKey2), "value_b")

        // Delete one, other should remain
        KeychainHelper.delete(key: testKey)
        XCTAssertNil(KeychainHelper.read(key: testKey))
        XCTAssertEqual(KeychainHelper.read(key: testKey2), "value_b")
    }

    // MARK: - Key Constants

    func testKeyConstants_defined() {
        XCTAssertEqual(KeychainHelper.accessTokenKey, "soilmate_access_token")
        XCTAssertEqual(KeychainHelper.refreshTokenKey, "soilmate_refresh_token")
    }
}
