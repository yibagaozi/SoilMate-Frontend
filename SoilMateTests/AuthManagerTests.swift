//
//  AuthManagerTests.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/23.
//

import XCTest
@testable import SoilMate

final class AuthManagerTests: XCTestCase {

    private var sut: AuthManager!

    override func setUp() {
        super.setUp()
        sut = AuthManager(isMock: true)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState_notLoggedIn() {
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Login (Mock)

    func testLogin_validCredentials_setsLoggedIn() async {
        await sut.login(email: "user@example.com", password: "12345678")

        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLogin_wrongPassword_setsError() async {
        await sut.login(email: "user@example.com", password: "wrong")

        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.errorMessage, "Invalid email or password")
    }

    func testLogin_invalidEmail_setsError() async {
        await sut.login(email: "noemail", password: "12345678")

        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertEqual(sut.errorMessage, "Invalid email or password")
    }

    func testLogin_setsLoadingDuringRequest() async {
        // Start login but don't await — check loading state
        let task = Task {
            await sut.login(email: "user@example.com", password: "12345678")
        }

        // Give the task a moment to start
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(sut.isLoading)

        await task.value
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Register (Mock)

    func testRegister_validInput_setsLoggedIn() async {
        await sut.register(email: "new@example.com", password: "12345678", displayName: "Test User")

        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testRegister_shortPassword_setsError() async {
        await sut.register(email: "new@example.com", password: "short", displayName: "Test User")

        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertEqual(sut.errorMessage, "Password must be at least 8 characters")
    }

    func testRegister_invalidEmail_setsError() async {
        await sut.register(email: "bad-email", password: "12345678", displayName: "Test User")

        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertEqual(sut.errorMessage, "Invalid email address")
    }

    // MARK: - Logout

    func testLogout_clearsLoggedInState() async {
        // First login
        await sut.login(email: "user@example.com", password: "12345678")
        XCTAssertTrue(sut.isLoggedIn)

        // Then logout
        sut.logout()
        XCTAssertFalse(sut.isLoggedIn)
    }

    // MARK: - Sequential Operations

    func testLogin_thenLogout_thenLogin() async {
        await sut.login(email: "user@example.com", password: "12345678")
        XCTAssertTrue(sut.isLoggedIn)

        sut.logout()
        XCTAssertFalse(sut.isLoggedIn)

        await sut.login(email: "user@example.com", password: "12345678")
        XCTAssertTrue(sut.isLoggedIn)
    }

    func testLogin_failureClearsOldError() async {
        // First: fail
        await sut.login(email: "bad", password: "wrong")
        XCTAssertNotNil(sut.errorMessage)

        // Second: succeed — error should clear
        await sut.login(email: "user@example.com", password: "12345678")
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.isLoggedIn)
    }
}
