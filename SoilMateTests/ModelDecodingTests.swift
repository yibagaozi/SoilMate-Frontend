//
//  ModelDecodingTests.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/23.
//

import XCTest
@testable import SoilMate

final class ModelDecodingTests: XCTestCase {

    private let decoder = JSONDecoder()

    // MARK: - ApiResponse

    func testApiResponse_withData() throws {
        let json = """
        {
            "code": 200,
            "message": "Success",
            "data": {"id": 1, "email": "test@test.com"}
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(ApiResponse<SimpleUser>.self, from: json)
        XCTAssertEqual(response.code, 200)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data?.id, 1)
        XCTAssertEqual(response.data?.email, "test@test.com")
    }

    func testApiResponse_withNullData() throws {
        let json = """
        {
            "code": 200,
            "message": "No content",
            "data": null
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(ApiResponse<SimpleUser>.self, from: json)
        XCTAssertTrue(response.success)
        XCTAssertNil(response.data)
    }

    func testApiResponse_errorCode() throws {
        let json = """
        {
            "code": 400,
            "message": "Invalid request",
            "data": null
        }
        """.data(using: .utf8)!

        let response = try decoder.decode(ApiResponse<SimpleUser>.self, from: json)
        XCTAssertFalse(response.success)
        XCTAssertEqual(response.message, "Invalid request")
    }

    // MARK: - AuthResponse

    func testAuthResponse_decodes() throws {
        let json = """
        {
            "user": {
                "id": 42,
                "email": "user@example.com",
                "displayName": "Test User",
                "avatarUrl": null,
                "timezone": "Asia/Tokyo",
                "notificationEnabled": true,
                "reminderTime": "09:00",
                "createdAt": "2026-01-01T00:00:00"
            },
            "tokens": {
                "accessToken": "abc123",
                "refreshToken": "def456",
                "expiresIn": 3600
            }
        }
        """.data(using: .utf8)!

        let auth = try decoder.decode(AuthResponse.self, from: json)
        XCTAssertEqual(auth.user.id, 42)
        XCTAssertEqual(auth.user.email, "user@example.com")
        XCTAssertEqual(auth.user.displayName, "Test User")
        XCTAssertNil(auth.user.avatarUrl)
        XCTAssertEqual(auth.tokens.accessToken, "abc123")
        XCTAssertEqual(auth.tokens.refreshToken, "def456")
        XCTAssertEqual(auth.tokens.expiresIn, 3600)
    }

    func testTokenResponse_optionalExpiresIn() throws {
        let json = """
        {
            "accessToken": "abc",
            "refreshToken": "def",
            "expiresIn": null
        }
        """.data(using: .utf8)!

        let tokens = try decoder.decode(TokenResponse.self, from: json)
        XCTAssertNil(tokens.expiresIn)
    }

    // MARK: - CareTaskItem

    func testCareTaskItem_wateringTask() throws {
        let json = """
        {
            "id": 10,
            "careType": "WATER",
            "scheduledDate": "2026-04-20",
            "status": "PENDING",
            "daysUntil": 2,
            "waterAmountMl": 200,
            "feedingType": null,
            "userPlantId": 5,
            "plantNickname": "Fernie",
            "plantImageUrl": null,
            "plantLocation": "Living Room",
            "potSize": "MEDIUM",
            "environment": "INDOOR"
        }
        """.data(using: .utf8)!

        let task = try decoder.decode(CareTaskItem.self, from: json)
        XCTAssertEqual(task.id, 10)
        XCTAssertTrue(task.isWatering)
        XCTAssertEqual(task.careTypeDisplay, "Watering")
        XCTAssertEqual(task.status, "PENDING")
        XCTAssertEqual(task.waterAmountMl, 200)
        XCTAssertEqual(task.userPlantId, 5)
        XCTAssertEqual(task.plantNickname, "Fernie")
        XCTAssertEqual(task.plantLocation, "Living Room")
        XCTAssertEqual(task.potSize, "MEDIUM")
        XCTAssertEqual(task.environment, "INDOOR")
    }

    func testCareTaskItem_feedingTask() throws {
        let json = """
        {
            "id": 11,
            "careType": "FEED",
            "scheduledDate": "2026-04-25",
            "status": "PENDING",
            "daysUntil": 7,
            "waterAmountMl": null,
            "feedingType": "Liquid fertilizer",
            "userPlantId": 5,
            "plantNickname": "Fernie",
            "plantImageUrl": null,
            "plantLocation": null,
            "potSize": null,
            "environment": null
        }
        """.data(using: .utf8)!

        let task = try decoder.decode(CareTaskItem.self, from: json)
        XCTAssertFalse(task.isWatering)
        XCTAssertEqual(task.careTypeDisplay, "Feeding")
        XCTAssertEqual(task.feedingType, "Liquid fertilizer")
    }

    // MARK: - CareLogItem

    func testCareLogItem_decodes() throws {
        let json = """
        {
            "id": 100,
            "taskId": 10,
            "careType": "WATER",
            "performedAt": "2026-04-18T10:30:00",
            "waterAmountMl": 250,
            "feedingType": null,
            "notes": "Soil was very dry",
            "userPlantId": 5,
            "plantNickname": "Fernie",
            "plantImageUrl": null,
            "plantLocation": "Living Room",
            "photoUrl": null
        }
        """.data(using: .utf8)!

        let log = try decoder.decode(CareLogItem.self, from: json)
        XCTAssertEqual(log.id, 100)
        XCTAssertTrue(log.isWatering)
        XCTAssertEqual(log.waterAmountMl, 250)
        XCTAssertEqual(log.notes, "Soil was very dry")
    }

    // MARK: - TaskDetail

    func testTaskDetail_withNextTask() throws {
        let json = """
        {
            "id": 10,
            "careType": "WATER",
            "scheduledDate": "2026-04-20",
            "waterAmountMl": 200,
            "feedingType": null,
            "status": "COMPLETED",
            "completedAt": "2026-04-20T09:15:00",
            "skipReason": null,
            "nextTaskId": 15,
            "nextTaskDate": "2026-05-04"
        }
        """.data(using: .utf8)!

        let detail = try decoder.decode(TaskDetail.self, from: json)
        XCTAssertEqual(detail.status, "COMPLETED")
        XCTAssertNotNil(detail.completedAt)
        XCTAssertEqual(detail.nextTaskId, 15)
        XCTAssertEqual(detail.nextTaskDate, "2026-05-04")
    }

    func testTaskDetail_skippedWithReason() throws {
        let json = """
        {
            "id": 10,
            "careType": "WATER",
            "scheduledDate": "2026-04-20",
            "waterAmountMl": null,
            "feedingType": null,
            "status": "SKIPPED",
            "completedAt": null,
            "skipReason": "Soil still moist",
            "nextTaskId": null,
            "nextTaskDate": null
        }
        """.data(using: .utf8)!

        let detail = try decoder.decode(TaskDetail.self, from: json)
        XCTAssertEqual(detail.status, "SKIPPED")
        XCTAssertEqual(detail.skipReason, "Soil still moist")
        XCTAssertNil(detail.nextTaskId)
    }

    // MARK: - Plant

    func testPlant_fullDecode() throws {
        let json = """
        {
            "id": 1,
            "name": "Snake Plant",
            "scientificName": "Dracaena trifasciata",
            "wateringIntervalDays": 14,
            "wateringAmountMl": 200,
            "feedingIntervalDays": 60,
            "feedingType": "General fertilizer",
            "sunlightRequirement": "LOW_LIGHT",
            "imageUrl": "https://example.com/snake.jpg",
            "note": "Very hardy"
        }
        """.data(using: .utf8)!

        let plant = try decoder.decode(Plant.self, from: json)
        XCTAssertEqual(plant.name, "Snake Plant")
        XCTAssertEqual(plant.scientificName, "Dracaena trifasciata")
        XCTAssertEqual(plant.wateringIntervalDays, 14)
        XCTAssertEqual(plant.sunlightRequirement, "LOW_LIGHT")
    }

    func testPlant_minimalDecode() throws {
        let json = """
        {
            "id": 2,
            "name": "Unknown Plant",
            "scientificName": null,
            "wateringIntervalDays": null,
            "wateringAmountMl": null,
            "feedingIntervalDays": null,
            "feedingType": null,
            "sunlightRequirement": null,
            "imageUrl": null,
            "note": null
        }
        """.data(using: .utf8)!

        let plant = try decoder.decode(Plant.self, from: json)
        XCTAssertEqual(plant.id, 2)
        XCTAssertNil(plant.scientificName)
        XCTAssertNil(plant.wateringIntervalDays)
    }

    // MARK: - UserProfile

    func testUserProfile_fullDecode() throws {
        let json = """
        {
            "id": 1,
            "email": "user@test.com",
            "displayName": "Plant Lover",
            "avatarUrl": "https://example.com/avatar.jpg",
            "timezone": "Asia/Tokyo",
            "notificationEnabled": true,
            "reminderTime": "09:00",
            "region": "TOKYO",
            "createdAt": "2026-01-01",
            "updatedAt": "2026-04-15",
            "authMethods": [
                {
                    "provider": "EMAIL",
                    "email": "user@test.com",
                    "isPrimary": true
                }
            ],
            "stats": {
                "totalPlants": 5,
                "activePlants": 4
            }
        }
        """.data(using: .utf8)!

        let profile = try decoder.decode(UserProfile.self, from: json)
        XCTAssertEqual(profile.displayName, "Plant Lover")
        XCTAssertEqual(profile.region, "TOKYO")
        XCTAssertEqual(profile.authMethods?.count, 1)
        XCTAssertEqual(profile.authMethods?.first?.provider, "EMAIL")
        XCTAssertEqual(profile.stats?.totalPlants, 5)
        XCTAssertEqual(profile.stats?.activePlants, 4)
    }

    // MARK: - UserPlantDetail

    func testUserPlantDetail_decodesComputedProperties() throws {
        let json = """
        {
            "id": 1,
            "nickname": "Fernie",
            "location": "Living Room",
            "photoUrl": null,
            "notes": null,
            "lastWateredAt": "2026-04-10T09:00:00",
            "lastFedAt": null,
            "createdAt": "2026-01-01",
            "plantId": 5,
            "plantName": "Boston Fern",
            "scientificName": "Nephrolepis exaltata",
            "sunlightRequirement": "PARTIAL_SUN",
            "plantImageUrl": null,
            "wateringIntervalDays": 7,
            "wateringAmountMl": 300,
            "feedingIntervalDays": 30,
            "feedingType": "Liquid fertilizer",
            "potSize": "LARGE",
            "environment": "OUTDOOR",
            "nextWateringDate": "2026-04-17",
            "nextFeedingDate": "2026-05-10",
            "recentCareLogs": []
        }
        """.data(using: .utf8)!

        let plant = try decoder.decode(UserPlantDetail.self, from: json)
        XCTAssertEqual(plant.nickname, "Fernie")
        XCTAssertEqual(plant.potSizeValue, .large)
        XCTAssertEqual(plant.environmentValue, .outdoor)

        // calculatedWaterAmountMl should apply Large (1.8) × Outdoor (1.3) × season
        let calculated = plant.calculatedWaterAmountMl
        XCTAssertNotNil(calculated)
        XCTAssertGreaterThan(calculated!, 300, "Large outdoor should increase base amount")
    }

    func testUserPlantDetail_nilPotSizeDefaultsToMedium() throws {
        let json = """
        {
            "id": 2,
            "nickname": null,
            "location": null,
            "photoUrl": null,
            "notes": null,
            "lastWateredAt": null,
            "lastFedAt": null,
            "createdAt": null,
            "plantId": null,
            "plantName": null,
            "scientificName": null,
            "sunlightRequirement": null,
            "plantImageUrl": null,
            "wateringIntervalDays": null,
            "wateringAmountMl": null,
            "feedingIntervalDays": null,
            "feedingType": null,
            "potSize": null,
            "environment": null,
            "nextWateringDate": null,
            "nextFeedingDate": null,
            "recentCareLogs": null
        }
        """.data(using: .utf8)!

        let plant = try decoder.decode(UserPlantDetail.self, from: json)
        XCTAssertEqual(plant.potSizeValue, .medium)
        XCTAssertEqual(plant.environmentValue, .indoor)
        XCTAssertNil(plant.calculatedWaterAmountMl, "No base amount → nil calculated")
    }

    // MARK: - Request Encoding

    func testLoginRequest_encodes() throws {
        let request = LoginRequest(email: "test@test.com", password: "secret123")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: String]

        XCTAssertEqual(dict["email"], "test@test.com")
        XCTAssertEqual(dict["password"], "secret123")
    }

    func testAddUserPlantRequest_encodes() throws {
        let request = AddUserPlantRequest(
            barcodeValue: "PLT-00001-A1",
            plantId: 5,
            nickname: "Fernie",
            location: "Balcony",
            potSize: "LARGE",
            environment: "OUTDOOR"
        )
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["barcodeValue"] as? String, "PLT-00001-A1")
        XCTAssertEqual(dict["plantId"] as? Int64, 5)
        XCTAssertEqual(dict["potSize"] as? String, "LARGE")
    }

}

// MARK: - Test Helpers

private struct SimpleUser: Decodable {
    let id: Int64
    let email: String
}
