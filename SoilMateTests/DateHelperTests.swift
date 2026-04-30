//
//  DateHelperTests.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/23.
//

import XCTest
@testable import SoilMate

final class DateHelperTests: XCTestCase {

    // MARK: - toDateString

    func testToDateString_formatsCorrectly() {
        let date = makeDate(year: 2026, month: 4, day: 15)
        XCTAssertEqual(DateHelper.toDateString(date), "2026-04-15")
    }

    func testToDateString_singleDigitMonthAndDay_zeroPadded() {
        let date = makeDate(year: 2026, month: 1, day: 5)
        XCTAssertEqual(DateHelper.toDateString(date), "2026-01-05")
    }

    func testToDateString_december31() {
        let date = makeDate(year: 2025, month: 12, day: 31)
        XCTAssertEqual(DateHelper.toDateString(date), "2025-12-31")
    }

    // MARK: - toDateTimeString

    func testToDateTimeString_formatsCorrectly() {
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 15
        components.hour = 9
        components.minute = 30
        components.second = 0
        let date = Calendar.current.date(from: components)!

        let result = DateHelper.toDateTimeString(date)
        XCTAssertEqual(result, "2026-04-15T09:30:00")
    }

    // MARK: - parseDate

    func testParseDate_validString() {
        let date = DateHelper.parseDate("2026-04-15")
        XCTAssertNotNil(date)

        let components = Calendar.current.dateComponents([.year, .month, .day], from: date!)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 15)
    }

    func testParseDate_nilString() {
        XCTAssertNil(DateHelper.parseDate(nil))
    }

    func testParseDate_invalidString() {
        XCTAssertNil(DateHelper.parseDate("not-a-date"))
    }

    func testParseDate_emptyString() {
        XCTAssertNil(DateHelper.parseDate(""))
    }

    func testParseDate_wrongFormat() {
        // "04/15/2026" is not "yyyy-MM-dd"
        XCTAssertNil(DateHelper.parseDate("04/15/2026"))
    }

    // MARK: - parseDateTime

    func testParseDateTime_validString() {
        let date = DateHelper.parseDateTime("2026-04-15T09:30:00")
        XCTAssertNotNil(date)

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: date!
        )
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 9)
        XCTAssertEqual(components.minute, 30)
        XCTAssertEqual(components.second, 0)
    }

    func testParseDateTime_nilString() {
        XCTAssertNil(DateHelper.parseDateTime(nil))
    }

    func testParseDateTime_invalidString() {
        XCTAssertNil(DateHelper.parseDateTime("2026-04-15"))
    }

    // MARK: - Round-trip: Date → String → Date

    func testRoundTrip_dateString() {
        let original = makeDate(year: 2026, month: 7, day: 20)
        let string = DateHelper.toDateString(original)
        let parsed = DateHelper.parseDate(string)

        XCTAssertNotNil(parsed)
        let originalComponents = Calendar.current.dateComponents([.year, .month, .day], from: original)
        let parsedComponents = Calendar.current.dateComponents([.year, .month, .day], from: parsed!)

        XCTAssertEqual(originalComponents.year, parsedComponents.year)
        XCTAssertEqual(originalComponents.month, parsedComponents.month)
        XCTAssertEqual(originalComponents.day, parsedComponents.day)
    }

    // MARK: - displayDate (from String)

    func testDisplayDate_fromValidString() {
        let result = DateHelper.displayDate("2026-04-15")
        XCTAssertEqual(result, "Apr 15, 2026")
    }

    func testDisplayDate_fromNilString() {
        let result = DateHelper.displayDate(nil as String?)
        XCTAssertEqual(result, "—")
    }

    func testDisplayDate_fromInvalidString() {
        let result = DateHelper.displayDate("garbage")
        XCTAssertEqual(result, "—")
    }

    // MARK: - displayDate (from Date)

    func testDisplayDate_fromDate() {
        let date = makeDate(year: 2025, month: 12, day: 25)
        let result = DateHelper.displayDate(date)
        XCTAssertEqual(result, "Dec 25, 2025")
    }

    // MARK: - displayTime

    func testDisplayTime_morning() {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let date = Calendar.current.date(from: components)!
        let result = DateHelper.displayTime(date)
        XCTAssertEqual(result, "9:00 AM")
    }

    func testDisplayTime_afternoon() {
        var components = DateComponents()
        components.hour = 14
        components.minute = 30
        let date = Calendar.current.date(from: components)!
        let result = DateHelper.displayTime(date)
        XCTAssertEqual(result, "2:30 PM")
    }

    // MARK: - relativeDayText

    func testRelativeDayText_today() {
        let todayStr = DateHelper.toDateString(Date())
        let result = DateHelper.relativeDayText(from: todayStr)
        XCTAssertEqual(result, "Today")
    }

    func testRelativeDayText_tomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowStr = DateHelper.toDateString(tomorrow)
        let result = DateHelper.relativeDayText(from: tomorrowStr)
        XCTAssertEqual(result, "Tomorrow")
    }

    func testRelativeDayText_inThreeDays() {
        let future = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        let futureStr = DateHelper.toDateString(future)
        let result = DateHelper.relativeDayText(from: futureStr)
        XCTAssertEqual(result, "In 3 Days")
    }

    func testRelativeDayText_overdue() {
        let past = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let pastStr = DateHelper.toDateString(past)
        let result = DateHelper.relativeDayText(from: pastStr)
        XCTAssertEqual(result, "Overdue")
    }

    func testRelativeDayText_nilString() {
        let result = DateHelper.relativeDayText(from: nil)
        XCTAssertEqual(result, "—")
    }

    func testRelativeDayText_invalidString() {
        let result = DateHelper.relativeDayText(from: "not-a-date")
        XCTAssertEqual(result, "—")
    }

    // MARK: - Helpers

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
}
