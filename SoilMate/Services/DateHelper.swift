//
//  DateHelper.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum DateHelper {

    // MARK: - Formatters (reused, not created every time)

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let dateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"  // "Apr 20, 2025"
        return f
    }()

    private static let displayTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"       // "8:00 AM"
        return f
    }()

    // MARK: - Date → String

    /// Convert Date to "yyyy-MM-dd" for API calls
    static func toDateString(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    /// Convert Date to "yyyy-MM-dd'T'HH:mm:ss" for API calls
    static func toDateTimeString(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }

    // MARK: - String → Date

    /// Parse "yyyy-MM-dd" from backend
    static func parseDate(_ string: String?) -> Date? {
        guard let string else { return nil }
        return dateFormatter.date(from: string)
    }

    /// Parse "yyyy-MM-dd'T'HH:mm:ss" from backend
    static func parseDateTime(_ string: String?) -> Date? {
        guard let string else { return nil }
        return dateTimeFormatter.date(from: string)
    }

    // MARK: - Display Strings

    /// "Apr 20, 2025" — for showing dates in the UI
    static func displayDate(_ string: String?) -> String {
        guard let date = parseDate(string) else { return "—" }
        return displayDateFormatter.string(from: date)
    }

    /// "Apr 20, 2025" — from a Date object
    static func displayDate(_ date: Date) -> String {
        displayDateFormatter.string(from: date)
    }

    /// "8:00 AM" — from a Date object
    static func displayTime(_ date: Date) -> String {
        displayTimeFormatter.string(from: date)
    }

    /// "Tomorrow", "Today", "In 3 Days", etc.
    static func relativeDayText(from dateString: String?) -> String {
        guard let date = parseDate(dateString) else { return "—" }
        let days = Calendar.current.dateComponents([.day], from: startOfToday(), to: date).day ?? 0

        switch days {
        case ..<0:    return "Overdue"
        case 0:       return "Today"
        case 1:       return "Tomorrow"
        default:      return "In \(days) Days"
        }
    }

    /// Start of today (midnight), used for date math
    private static func startOfToday() -> Date {
        Calendar.current.startOfDay(for: Date())
    }
}
