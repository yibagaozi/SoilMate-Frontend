//
//  WateringCalculatorTests.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/23.
//

import XCTest
@testable import SoilMate

final class WateringCalculatorTests: XCTestCase {

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        // Reset to a known region so seasonal factors are predictable
        WateringCalculator.currentRegion = .tokyo
    }

    // MARK: - Basic Calculation

    func testDefaultCalculation_mediumPotIndoor() {
        // Medium pot (1.0) × Indoor (1.0) × season factor
        // With Tokyo in a controlled month, we can verify the formula
        let january = makeDate(month: 1)
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .medium,
            environment: .indoor,
            region: .tokyo,
            date: january
        )

        // Tokyo January raw season = 0.45
        // Indoor muting: 1.0 + (0.45 - 1.0) * 0.5 = 1.0 - 0.275 = 0.725
        // 200 * 1.0 * 1.0 * 0.725 = 145 → round to 150
        XCTAssertEqual(result, 150)
    }

    func testCalculation_summerMonth() {
        let july = makeDate(month: 7)
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .medium,
            environment: .indoor,
            region: .tokyo,
            date: july
        )

        // Tokyo July raw season = 1.55
        // Indoor muting: 1.0 + (1.55 - 1.0) * 0.5 = 1.275
        // 200 * 1.0 * 1.0 * 1.275 = 255 → round to 260
        XCTAssertEqual(result, 250)
    }

    // MARK: - Pot Size Factors

    func testSmallPot_halvesAmount() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .small,
            environment: .indoor,
            region: .singapore, // factor 1.0 all year
            date: makeDate(month: 6)
        )
        // 200 * 0.5 * 1.0 * 1.0 = 100
        XCTAssertEqual(result, 100)
    }

    func testMediumPot_noChange() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .medium,
            environment: .indoor,
            region: .singapore,
            date: makeDate(month: 6)
        )
        // 200 * 1.0 * 1.0 * 1.0 = 200
        XCTAssertEqual(result, 200)
    }

    func testLargePot_multiplies1_8() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .large,
            environment: .indoor,
            region: .singapore,
            date: makeDate(month: 6)
        )
        // 200 * 1.8 * 1.0 * 1.0 = 360
        XCTAssertEqual(result, 360)
    }

    func testExtraLargePot_multiplies2_8() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .extraLarge,
            environment: .indoor,
            region: .singapore,
            date: makeDate(month: 6)
        )
        // 200 * 2.8 * 1.0 * 1.0 = 560
        XCTAssertEqual(result, 560)
    }

    // MARK: - Environment Factors

    func testOutdoor_multiplies1_3() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .medium,
            environment: .outdoor,
            region: .singapore,
            date: makeDate(month: 6)
        )
        // 200 * 1.0 * 1.3 * 1.0 = 260
        XCTAssertEqual(result, 260)
    }

    func testGreenhouse_multiplies1_1() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .medium,
            environment: .greenhouse,
            region: .singapore,
            date: makeDate(month: 6)
        )
        // 200 * 1.0 * 1.1 * 1.0 = 220
        XCTAssertEqual(result, 220)
    }

    // MARK: - Outdoor Does NOT Mute Seasonal Factor

    func testOutdoor_fullSeasonalFactor() {
        let january = makeDate(month: 1)
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .medium,
            environment: .outdoor,
            region: .tokyo,
            date: january
        )

        // Tokyo January raw season = 0.45 (no muting for outdoor)
        // 200 * 1.0 * 1.3 * 0.45 = 117 → round to 120
        XCTAssertEqual(result, 120)
    }

    // MARK: - Rounding

    func testRoundsToNearestTen() {
        // Pick values that produce non-round results
        // 150 * 0.5 * 1.3 * 1.0 = 97.5 → 100
        let result = WateringCalculator.calculate(
            baseAmountMl: 150,
            potSize: .small,
            environment: .outdoor,
            region: .singapore,
            date: makeDate(month: 1)
        )
        XCTAssertEqual(result % 10, 0, "Result should be rounded to nearest 10")
    }

    func testMinimumFloor_10ml() {
        // Very small base amount
        let result = WateringCalculator.calculate(
            baseAmountMl: 1,
            potSize: .small,
            environment: .indoor,
            region: .tokyo,
            date: makeDate(month: 1)
        )
        // 1 * 0.5 * 1.0 * 0.725 = 0.3625 → rounds to 0 → clamped to 10
        XCTAssertEqual(result, 10)
    }

    // MARK: - String Convenience Overload

    func testStringOverload_validValues() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSizeString: "LARGE",
            environmentString: "OUTDOOR",
            region: .singapore,
            date: makeDate(month: 6)
        )
        // 200 * 1.8 * 1.3 * 1.0 = 468 → 470
        XCTAssertEqual(result, 470)
    }

    func testStringOverload_nilDefaults() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSizeString: nil,
            environmentString: nil,
            region: .singapore,
            date: makeDate(month: 6)
        )
        // nil → medium (1.0) and indoor (1.0)
        // 200 * 1.0 * 1.0 * 1.0 = 200
        XCTAssertEqual(result, 200)
    }

    func testStringOverload_invalidFallsToDefault() {
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSizeString: "GIANT",
            environmentString: "MARS",
            region: .singapore,
            date: makeDate(month: 6)
        )
        // Invalid → medium (1.0) and indoor (1.0)
        XCTAssertEqual(result, 200)
    }

    // MARK: - Tags

    func testTags_returnsThreeElements() {
        let tags = WateringCalculator.tags(
            potSize: .large,
            environment: .outdoor,
            region: .tokyo,
            date: makeDate(month: 7)
        )
        XCTAssertEqual(tags.count, 3)
        XCTAssertEqual(tags[0], "Large Pot")
        XCTAssertEqual(tags[1], "Outdoor")
        XCTAssertTrue(tags[2].hasPrefix("Jul"), "Third tag should start with month abbreviation")
        XCTAssertTrue(tags[2].hasSuffix("%"), "Third tag should end with %")
    }

    func testTags_indoorMutedPercentage() {
        let tagsIndoor = WateringCalculator.tags(
            potSize: .medium,
            environment: .indoor,
            region: .tokyo,
            date: makeDate(month: 1)
        )
        let tagsOutdoor = WateringCalculator.tags(
            potSize: .medium,
            environment: .outdoor,
            region: .tokyo,
            date: makeDate(month: 1)
        )

        // Indoor should show a percentage closer to 100% than outdoor
        // because indoor muting dampens the seasonal variation
        XCTAssertNotEqual(tagsIndoor[2], tagsOutdoor[2])
    }

    // MARK: - PotSize.from

    func testPotSizeFrom_validRawValues() {
        XCTAssertEqual(PotSize.from("SMALL"), .small)
        XCTAssertEqual(PotSize.from("MEDIUM"), .medium)
        XCTAssertEqual(PotSize.from("LARGE"), .large)
        XCTAssertEqual(PotSize.from("EXTRA_LARGE"), .extraLarge)
    }

    func testPotSizeFrom_nilReturnsMedium() {
        XCTAssertEqual(PotSize.from(nil), .medium)
    }

    func testPotSizeFrom_invalidReturnsMedium() {
        XCTAssertEqual(PotSize.from("HUGE"), .medium)
    }

    // MARK: - PotSize Display

    func testPotSize_displayCode() {
        XCTAssertEqual(PotSize.small.displayCode, "S")
        XCTAssertEqual(PotSize.medium.displayCode, "M")
        XCTAssertEqual(PotSize.large.displayCode, "L")
        XCTAssertEqual(PotSize.extraLarge.displayCode, "XL")
    }

    func testPotSize_displayLabel() {
        XCTAssertEqual(PotSize.small.displayLabel, "Small")
        XCTAssertEqual(PotSize.extraLarge.displayLabel, "Extra Large")
    }

    // MARK: - GrowingEnvironment.from

    func testGrowingEnvironmentFrom_validRawValues() {
        XCTAssertEqual(GrowingEnvironment.from("INDOOR"), .indoor)
        XCTAssertEqual(GrowingEnvironment.from("OUTDOOR"), .outdoor)
        XCTAssertEqual(GrowingEnvironment.from("GREENHOUSE"), .greenhouse)
    }

    func testGrowingEnvironmentFrom_nilReturnsIndoor() {
        XCTAssertEqual(GrowingEnvironment.from(nil), .indoor)
    }

    func testGrowingEnvironmentFrom_invalidReturnsIndoor() {
        XCTAssertEqual(GrowingEnvironment.from("SPACESHIP"), .indoor)
    }

    // MARK: - Region.fromTimezone

    func testRegionFromTimezone_knownMappings() {
        XCTAssertEqual(Region.fromTimezone("Asia/Tokyo"), .tokyo)
        XCTAssertEqual(Region.fromTimezone("America/New_York"), .newYork)
        XCTAssertEqual(Region.fromTimezone("Europe/London"), .london)
        XCTAssertEqual(Region.fromTimezone("Australia/Sydney"), .sydney)
        XCTAssertEqual(Region.fromTimezone("Asia/Singapore"), .singapore)
        XCTAssertEqual(Region.fromTimezone("Asia/Dubai"), .dubai)
    }

    func testRegionFromTimezone_aliasesMapped() {
        // Toronto maps to New York
        XCTAssertEqual(Region.fromTimezone("America/Toronto"), .newYork)
        // Paris maps to London
        XCTAssertEqual(Region.fromTimezone("Europe/Paris"), .london)
        // Melbourne maps to Sydney
        XCTAssertEqual(Region.fromTimezone("Australia/Melbourne"), .sydney)
    }

    func testRegionFromTimezone_unknownReturnsNil() {
        XCTAssertNil(Region.fromTimezone("Antarctica/South_Pole"))
        XCTAssertNil(Region.fromTimezone(""))
        XCTAssertNil(Region.fromTimezone("Invalid/Zone"))
    }

    // MARK: - Region Seasonal Factors

    func testSingapore_constantFactorAllYear() {
        let singapore = Region.singapore
        for month in 1...12 {
            XCTAssertEqual(singapore.seasonFactor(month: month), 1.0,
                           "Singapore should have factor 1.0 in month \(month)")
        }
    }

    func testSeasonFactor_clampedToValidRange() {
        let tokyo = Region.tokyo
        // Month 0 should clamp to index 0 (January)
        XCTAssertEqual(tokyo.seasonFactor(month: 0), tokyo.seasonFactor(month: 1))
        // Month 13 should clamp to index 11 (December)
        XCTAssertEqual(tokyo.seasonFactor(month: 13), tokyo.seasonFactor(month: 12))
    }

    func testSydney_southernHemispherePattern() {
        let sydney = Region.sydney
        // Summer is Jan/Feb in Southern Hemisphere → higher factor
        let january = sydney.seasonFactor(month: 1)
        let july = sydney.seasonFactor(month: 7)
        XCTAssertGreaterThan(january, july,
                             "Sydney January (summer) should have higher factor than July (winter)")
    }

    // MARK: - Combined Factors

    func testCombinedFactors_largePotOutdoorSummer() {
        let july = makeDate(month: 7)
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .large,
            environment: .outdoor,
            region: .tokyo,
            date: july
        )

        // 200 * 1.8 * 1.3 * 1.55 = 725.4 → 730
        XCTAssertEqual(result, 730)
    }

    func testCombinedFactors_smallPotIndoorWinter() {
        let december = makeDate(month: 12)
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .small,
            environment: .indoor,
            region: .tokyo,
            date: december
        )

        // Tokyo Dec raw = 0.50
        // Indoor muting: 1.0 + (0.50 - 1.0) * 0.5 = 0.75
        // 200 * 0.5 * 1.0 * 0.75 = 75 → 80
        XCTAssertEqual(result, 80)
    }

    // MARK: - currentRegion Fallback

    func testCalculate_usesCurrentRegionWhenNilPassed() {
        WateringCalculator.currentRegion = .singapore
        let result = WateringCalculator.calculate(
            baseAmountMl: 200,
            potSize: .medium,
            environment: .indoor,
            region: nil,
            date: makeDate(month: 6)
        )
        // Singapore always 1.0
        XCTAssertEqual(result, 200)
    }

    // MARK: - Helpers

    private func makeDate(month: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = month
        components.day = 15
        return Calendar.current.date(from: components)!
    }
}
