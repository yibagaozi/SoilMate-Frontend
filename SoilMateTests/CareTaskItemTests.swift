//
//  CareTaskItemTests.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/23.
//

import XCTest
@testable import SoilMate

final class CareTaskItemTests: XCTestCase {

    private let decoder = JSONDecoder()

    override func setUp() {
        super.setUp()
        // Use Singapore (factor 1.0 all year) for predictable tests
        WateringCalculator.currentRegion = .singapore
    }

    // MARK: - isWatering

    func testIsWatering_waterType() {
        let task = makeTask(careType: "WATER")
        XCTAssertTrue(task.isWatering)
    }

    func testIsWatering_feedType() {
        let task = makeTask(careType: "FEED")
        XCTAssertFalse(task.isWatering)
    }

    // MARK: - careTypeDisplay

    func testCareTypeDisplay_watering() {
        let task = makeTask(careType: "WATER")
        XCTAssertEqual(task.careTypeDisplay, "Watering")
    }

    func testCareTypeDisplay_feeding() {
        let task = makeTask(careType: "FEED")
        XCTAssertEqual(task.careTypeDisplay, "Feeding")
    }

    // MARK: - displayedWaterAmountMl

    func testDisplayedWaterAmountMl_wateringTaskWithAmount() {
        let task = makeTask(
            careType: "WATER",
            waterAmountMl: 200,
            potSize: "MEDIUM",
            environment: "INDOOR"
        )

        // Singapore + Medium + Indoor = 200 * 1.0 * 1.0 * 1.0 = 200
        XCTAssertEqual(task.displayedWaterAmountMl, 200)
    }

    func testDisplayedWaterAmountMl_largePotOutdoor() {
        let task = makeTask(
            careType: "WATER",
            waterAmountMl: 200,
            potSize: "LARGE",
            environment: "OUTDOOR"
        )

        // Singapore + Large (1.8) + Outdoor (1.3) = 200 * 1.8 * 1.3 * 1.0 = 468 → 470
        XCTAssertEqual(task.displayedWaterAmountMl, 470)
    }

    func testDisplayedWaterAmountMl_nilForFeedingTask() {
        let task = makeTask(careType: "FEED", waterAmountMl: nil)
        XCTAssertNil(task.displayedWaterAmountMl)
    }

    func testDisplayedWaterAmountMl_nilWhenNoBaseAmount() {
        let task = makeTask(careType: "WATER", waterAmountMl: nil)
        XCTAssertNil(task.displayedWaterAmountMl)
    }

    func testDisplayedWaterAmountMl_nilPotSizeDefaultsToMedium() {
        let task = makeTask(
            careType: "WATER",
            waterAmountMl: 200,
            potSize: nil,
            environment: nil
        )

        // nil → Medium (1.0), nil → Indoor (1.0), Singapore (1.0)
        XCTAssertEqual(task.displayedWaterAmountMl, 200)
    }

    // MARK: - displayDetail

    func testDisplayDetail_wateringWithAmount() {
        let task = makeTask(
            careType: "WATER",
            waterAmountMl: 200,
            potSize: "MEDIUM",
            environment: "INDOOR"
        )
        XCTAssertEqual(task.displayDetail, "200ml")
    }

    func testDisplayDetail_wateringWithAdjustedAmount() {
        let task = makeTask(
            careType: "WATER",
            waterAmountMl: 200,
            potSize: "LARGE",
            environment: "OUTDOOR"
        )
        // 470ml (see calculation above)
        XCTAssertEqual(task.displayDetail, "470ml")
    }

    func testDisplayDetail_wateringWithoutAmount() {
        let task = makeTask(careType: "WATER", waterAmountMl: nil)
        XCTAssertEqual(task.displayDetail, "Water")
    }

    func testDisplayDetail_feedingWithType() {
        let task = makeTask(careType: "FEED", feedingType: "Liquid fertilizer")
        XCTAssertEqual(task.displayDetail, "Liquid fertilizer")
    }

    func testDisplayDetail_feedingWithoutType() {
        let task = makeTask(careType: "FEED", feedingType: nil)
        XCTAssertEqual(task.displayDetail, "Fertilizer")
    }

    // MARK: - Equatable Conformance

    func testEquatable_sameId() {
        let task1 = makeTask(id: 42, careType: "WATER")
        let task2 = makeTask(id: 42, careType: "FEED")
        XCTAssertEqual(task1, task2, "Tasks with same ID should be equal")
    }

    func testEquatable_differentId() {
        let task1 = makeTask(id: 1, careType: "WATER")
        let task2 = makeTask(id: 2, careType: "WATER")
        XCTAssertNotEqual(task1, task2)
    }

    // MARK: - JSON Decoding Integration

    func testDecoding_allFieldsPresent() throws {
        let json = """
        {
            "id": 99,
            "careType": "WATER",
            "scheduledDate": "2026-05-01",
            "status": "COMPLETED",
            "daysUntil": 0,
            "waterAmountMl": 150,
            "feedingType": null,
            "userPlantId": 7,
            "plantNickname": "My Fern",
            "plantImageUrl": "https://example.com/fern.jpg",
            "plantLocation": "Bedroom",
            "potSize": "SMALL",
            "environment": "GREENHOUSE"
        }
        """.data(using: .utf8)!

        let task = try decoder.decode(CareTaskItem.self, from: json)
        XCTAssertEqual(task.id, 99)
        XCTAssertEqual(task.status, "COMPLETED")
        XCTAssertEqual(task.plantNickname, "My Fern")
        XCTAssertEqual(task.potSize, "SMALL")
        XCTAssertEqual(task.environment, "GREENHOUSE")
    }

    func testDecoding_minimalOptionalFields() throws {
        let json = """
        {
            "id": 1,
            "careType": "FEED",
            "scheduledDate": "2026-05-01",
            "status": "PENDING",
            "daysUntil": null,
            "waterAmountMl": null,
            "feedingType": null,
            "userPlantId": 3,
            "plantNickname": null,
            "plantImageUrl": null,
            "plantLocation": null,
            "potSize": null,
            "environment": null
        }
        """.data(using: .utf8)!

        let task = try decoder.decode(CareTaskItem.self, from: json)
        XCTAssertFalse(task.isWatering)
        XCTAssertNil(task.plantNickname)
        XCTAssertNil(task.displayedWaterAmountMl)
        XCTAssertEqual(task.displayDetail, "Fertilizer")
    }

    // MARK: - Helpers

    private func makeTask(
        id: Int64 = 1,
        careType: String = "WATER",
        waterAmountMl: Int? = nil,
        feedingType: String? = nil,
        potSize: String? = "MEDIUM",
        environment: String? = "INDOOR"
    ) -> CareTaskItem {
        let json: [String: Any?] = [
            "id": id,
            "careType": careType,
            "scheduledDate": "2026-04-20",
            "status": "PENDING",
            "daysUntil": 0,
            "waterAmountMl": waterAmountMl as Any?,
            "feedingType": feedingType as Any?,
            "userPlantId": 5,
            "plantNickname": "TestPlant",
            "plantImageUrl": nil,
            "plantLocation": nil,
            "potSize": potSize as Any?,
            "environment": environment as Any?
        ]

        let data = try! JSONSerialization.data(withJSONObject: json.compactMapValues { $0 ?? NSNull() })
        return try! decoder.decode(CareTaskItem.self, from: data)
    }
}
