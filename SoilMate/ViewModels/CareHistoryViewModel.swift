//
//  CareHistoryViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation

@Observable
final class CareHistoryViewModel {

    // MARK: - State

    /// Selected year for filtering
    var selectedYear: Int {
        didSet { Task { await loadLogs() } }
    }

    /// Selected month (1-12) for filtering
    var selectedMonth: Int {
        didSet { Task { await loadLogs() } }
    }

    /// The plant we are viewing history for
    let userPlantId: Int64

    /// Care logs for the selected month
    var logs: [CareLogItem] = []

    var isLoading = false
    var errorMessage: String?

    // MARK: - Init

    init(userPlantId: Int64) {
        self.userPlantId = userPlantId

        // Default to current year and month
        let now = Calendar.current.dateComponents([.year, .month], from: Date())
        self.selectedYear = now.year ?? 2025
        self.selectedMonth = now.month ?? 1
    }

    // MARK: - Load

    /// Fetch logs for the selected month.
    /// We load each day of the month and combine results.
    /// A better approach: ask backend to support month-range query.
    /// For now, we load day-by-day for the selected month.
    func loadLogs() async {
        isLoading = true
        errorMessage = nil

        // Build all dates in the selected month
        let dates = datesInMonth(year: selectedYear, month: selectedMonth)

        var allLogs: [CareLogItem] = []

        do {
            // Fetch logs for each date in the month
            // This could be optimized with a backend month endpoint
            for date in dates {
                let dayLogs = try await CareLogService.getLogsByDate(
                    date: date,
                    userPlantId: userPlantId
                )
                allLogs.append(contentsOf: dayLogs)
            }

            // Sort by date, newest first
            self.logs = allLogs.sorted { ($0.performedAt ?? "") > ($1.performedAt ?? "") }
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load care history"
        }

        isLoading = false
    }

    // MARK: - Helpers

    /// Get all "yyyy-MM-dd" strings for days in a month
    private func datesInMonth(year: Int, month: Int) -> [String] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let startDate = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startDate)
        else { return [] }

        return range.map { day in
            var dayComp = components
            dayComp.day = day
            if let date = calendar.date(from: dayComp) {
                return DateHelper.toDateString(date)
            }
            return ""
        }.filter { !$0.isEmpty }
    }

    /// Display date: "Dec 25, 2025"
    func displayDate(_ log: CareLogItem) -> String {
        guard let dateStr = log.performedAt else { return "—" }
        guard let date = DateHelper.parseDateTime(dateStr) else { return dateStr }
        return DateHelper.displayDate(date)
    }

    /// "200 ml" or "General fertilizer"
    func detailText(_ log: CareLogItem) -> String {
        if log.isWatering {
            return log.waterAmountMl.map { "\($0) ml" } ?? "Watered"
        } else {
            return log.feedingType ?? "Fed"
        }
    }
}
