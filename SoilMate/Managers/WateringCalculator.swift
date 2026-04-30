//
//  WateringCalculator.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import Foundation
 
// MARK: - Pot Size
 
enum PotSize: String, Codable, CaseIterable {
    case small = "SMALL"
    case medium = "MEDIUM"
    case large = "LARGE"
    case extraLarge = "EXTRA_LARGE"
 
    var displayCode: String {
        switch self {
        case .small: return "S"
        case .medium: return "M"
        case .large: return "L"
        case .extraLarge: return "XL"
        }
    }
 
    var displayLabel: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "Extra Large"
        }
    }
 
    /// Multiplier applied to base watering amount. Softened from pure
    /// volume scaling to account for saturation efficiency.
    var factor: Double {
        switch self {
        case .small: return 0.5
        case .medium: return 1.0
        case .large: return 1.8
        case .extraLarge: return 2.8
        }
    }
 
    static func from(_ value: String?) -> PotSize {
        guard let value else { return .medium }
        return PotSize(rawValue: value) ?? .medium
    }
}
 
// MARK: - Growing Environment
 
enum GrowingEnvironment: String, Codable, CaseIterable {
    case indoor = "INDOOR"
    case outdoor = "OUTDOOR"
    case greenhouse = "GREENHOUSE"
 
    var displayLabel: String {
        switch self {
        case .indoor: return "Indoor"
        case .outdoor: return "Outdoor"
        case .greenhouse: return "Greenhouse"
        }
    }
 
    /// Indoor = 1.0 reference. Outdoor = 1.3 (sun, wind). Greenhouse = 1.1.
    /// v1 approximations; no extension publishes hard numbers.
    var factor: Double {
        switch self {
        case .indoor: return 1.0
        case .outdoor: return 1.3
        case .greenhouse: return 1.1
        }
    }
 
    static func from(_ value: String?) -> GrowingEnvironment {
        guard let value else { return .indoor }
        return GrowingEnvironment(rawValue: value) ?? .indoor
    }
}
 
// MARK: - Region
 
enum Region: String, Codable, CaseIterable, Identifiable {
    case tokyo = "TOKYO"
    case beijing = "BEIJING"
    case shanghai = "SHANGHAI"
    case hongKong = "HONG_KONG"
    case singapore = "SINGAPORE"
    case london = "LONDON"
    case newYork = "NEW_YORK"
    case losAngeles = "LOS_ANGELES"
    case sydney = "SYDNEY"
    case dubai = "DUBAI"
 
    var id: String { rawValue }
 
    var displayName: String {
        switch self {
        case .tokyo: return "Tokyo"
        case .beijing: return "Beijing"
        case .shanghai: return "Shanghai"
        case .hongKong: return "Hong Kong"
        case .singapore: return "Singapore"
        case .london: return "London"
        case .newYork: return "New York"
        case .losAngeles: return "Los Angeles"
        case .sydney: return "Sydney"
        case .dubai: return "Dubai"
        }
    }
 
    /// Monthly seasonal factors (index 0 = January).
    /// Derived from published FAO-56 ETo patterns for each climate zone.
    var monthlyFactors: [Double] {
        switch self {
        case .tokyo:      return [0.45, 0.55, 0.80, 1.05, 1.25, 1.35, 1.55, 1.50, 1.20, 0.90, 0.65, 0.50]
        case .beijing:    return [0.35, 0.50, 0.85, 1.20, 1.45, 1.65, 1.55, 1.40, 1.15, 0.85, 0.50, 0.35]
        case .shanghai:   return [0.50, 0.60, 0.85, 1.05, 1.25, 1.30, 1.55, 1.50, 1.15, 0.90, 0.70, 0.55]
        case .hongKong:   return [0.70, 0.75, 0.85, 1.00, 1.15, 1.20, 1.30, 1.30, 1.20, 1.10, 0.90, 0.75]
        case .singapore:  return [1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00]
        case .london:     return [0.30, 0.45, 0.75, 1.10, 1.45, 1.60, 1.65, 1.45, 1.10, 0.70, 0.40, 0.30]
        case .newYork:    return [0.35, 0.45, 0.75, 1.10, 1.35, 1.50, 1.60, 1.45, 1.20, 0.85, 0.55, 0.40]
        case .losAngeles: return [0.55, 0.65, 0.85, 1.05, 1.20, 1.35, 1.50, 1.50, 1.25, 1.00, 0.70, 0.55]
        case .sydney:     return [1.45, 1.35, 1.15, 0.90, 0.70, 0.55, 0.55, 0.70, 0.90, 1.10, 1.30, 1.40]
        case .dubai:      return [0.50, 0.65, 0.90, 1.20, 1.45, 1.60, 1.65, 1.60, 1.35, 1.05, 0.75, 0.55]
        }
    }
 
    func seasonFactor(month: Int) -> Double {
        let index = max(0, min(11, month - 1))
        return monthlyFactors[index]
    }
 
    /// Map a timezone identifier to a supported region. Returns nil if
    /// no match, letting the caller decide the fallback.
    static func fromTimezone(_ identifier: String) -> Region? {
        return timezoneMap[identifier]
    }
 
    private static let timezoneMap: [String: Region] = [
        "Asia/Tokyo": .tokyo,
        "Asia/Shanghai": .shanghai,
        "Asia/Urumqi": .shanghai,
        "Asia/Hong_Kong": .hongKong,
        "Asia/Macau": .hongKong,
        "Asia/Taipei": .hongKong,
        "Asia/Singapore": .singapore,
        "Asia/Kuala_Lumpur": .singapore,
        "Asia/Jakarta": .singapore,
        "Asia/Bangkok": .singapore,
        "Asia/Manila": .singapore,
        "Europe/London": .london,
        "Europe/Dublin": .london,
        "Europe/Lisbon": .london,
        "Europe/Paris": .london,
        "Europe/Berlin": .london,
        "Europe/Madrid": .london,
        "Europe/Rome": .london,
        "Europe/Amsterdam": .london,
        "Europe/Brussels": .london,
        "America/New_York": .newYork,
        "America/Toronto": .newYork,
        "America/Chicago": .newYork,
        "America/Los_Angeles": .losAngeles,
        "America/Vancouver": .losAngeles,
        "America/Tijuana": .losAngeles,
        "Australia/Sydney": .sydney,
        "Australia/Melbourne": .sydney,
        "Australia/Brisbane": .sydney,
        "Pacific/Auckland": .sydney,
        "Asia/Dubai": .dubai,
        "Asia/Riyadh": .dubai,
        "Asia/Kuwait": .dubai,
    ]
}
 
// MARK: - Calculator
 
enum WateringCalculator {
 
    /// Indoor plants experience half as much seasonal variation because
    /// HVAC stabilizes temperature. v1 approximation, tunable.
    static let indoorSeasonalMuting: Double = 0.5
 
    /// Default region used when the user has not set one and auto-detect fails.
    static let defaultRegion: Region = .tokyo
 
    /// The current region. Read from SettingsViewModel or wherever the
    /// user's profile is held. For convenience in places without direct
    /// access to the profile, we cache the last-used region here.
    ///
    /// This is a simple in-memory cache set by SettingsViewModel when
    /// the profile loads. No UserDefaults, no persistence - on cold
    /// launch it falls back to timezone auto-detect until the profile
    /// loads from the server.
    static var currentRegion: Region = autoDetectRegion()
 
    // MARK: - Auto-Detect
 
    static func autoDetectRegion() -> Region {
        Region.fromTimezone(TimeZone.current.identifier) ?? defaultRegion
    }
 
    // MARK: - Core Calculation
 
    /// Calculate the adjusted watering amount for the given parameters.
    /// Rounds to the nearest 10ml.
    static func calculate(
        baseAmountMl: Int,
        potSize: PotSize,
        environment: GrowingEnvironment,
        region: Region? = nil,
        date: Date = Date()
    ) -> Int {
        let region = region ?? currentRegion
        let month = Calendar.current.component(.month, from: date)
        let rawSeason = region.seasonFactor(month: month)
 
        let effectiveSeason = (environment == .indoor)
            ? 1.0 + (rawSeason - 1.0) * indoorSeasonalMuting
            : rawSeason
 
        let raw = Double(baseAmountMl)
            * potSize.factor
            * environment.factor
            * effectiveSeason
 
        return roundToTen(raw)
    }
 
    /// Convenience overload that takes raw strings (for CareTaskItem and
    /// UserPlantDetail which carry optional string fields from the API).
    static func calculate(
        baseAmountMl: Int,
        potSizeString: String?,
        environmentString: String?,
        region: Region? = nil,
        date: Date = Date()
    ) -> Int {
        calculate(
            baseAmountMl: baseAmountMl,
            potSize: PotSize.from(potSizeString),
            environment: GrowingEnvironment.from(environmentString),
            region: region,
            date: date
        )
    }
 
    // MARK: - Breakdown (for UI tags)
 
    /// Short tag strings showing why this number. Example: ["Medium Pot", "Indoor", "Dec 73%"]
    static func tags(
        potSize: PotSize,
        environment: GrowingEnvironment,
        region: Region? = nil,
        date: Date = Date()
    ) -> [String] {
        let region = region ?? currentRegion
        let month = Calendar.current.component(.month, from: date)
        let rawSeason = region.seasonFactor(month: month)
        let effectiveSeason = (environment == .indoor)
            ? 1.0 + (rawSeason - 1.0) * indoorSeasonalMuting
            : rawSeason
 
        let monthName = Calendar.current.shortMonthSymbols[max(0, min(11, month - 1))]
        let seasonPercent = Int((effectiveSeason * 100).rounded())
 
        return [
            "\(potSize.displayLabel) Pot",
            environment.displayLabel,
            "\(monthName) \(seasonPercent)%"
        ]
    }
 
    // MARK: - Helpers
 
    private static func roundToTen(_ value: Double) -> Int {
        let rounded = (value / 10.0).rounded() * 10.0
        return max(10, Int(rounded))
    }
}
