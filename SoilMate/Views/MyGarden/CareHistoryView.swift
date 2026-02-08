//
//  CareHistoryView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/8.
//

import SwiftUI

// MARK: - Static Care Record

private struct CareRecord: Identifiable {
    let id = UUID()
    let type: CareType
    let detail: String
    let date: String
    let month: Int      // for filtering
    let year: Int       // for filtering
    let note: String?

    enum CareType {
        case watering, feeding

        var label: String {
            switch self {
            case .watering: return "Watering"
            case .feeding: return "Feeding"
            }
        }

        var color: Color {
            switch self {
            case .watering: return .blue
            case .feeding: return .orange
            }
        }
    }
}

private let allRecords: [CareRecord] = [
    CareRecord(type: .watering, detail: "200 ml", date: "Dec 25, 2025",
               month: 12, year: 2025, note: "Leaves looking healthy after watering"),
    CareRecord(type: .feeding, detail: "General fertilizer", date: "Dec 11, 2025",
               month: 12, year: 2025, note: nil),
    CareRecord(type: .watering, detail: "200 ml", date: "Dec 11, 2025",
               month: 12, year: 2025, note: "Leaves looking good after watering"),
    CareRecord(type: .watering, detail: "200 ml", date: "Nov 28, 2025",
               month: 11, year: 2025, note: nil),
    CareRecord(type: .feeding, detail: "Liquid fertilizer", date: "Nov 15, 2025",
               month: 11, year: 2025, note: "Applied half-strength"),
    CareRecord(type: .watering, detail: "150 ml", date: "Oct 20, 2025",
               month: 10, year: 2025, note: "Soil was very dry"),
]

// MARK: - Care History View

struct CareHistoryView: View {

    @State private var selectedYear = 2025
    @State private var selectedMonth = 12

    private let years = [2024, 2025, 2026]
    private let months = Calendar.current.monthSymbols   // ["January", ..., "December"]

    /// Filtered records by selected year & month
    private var filteredRecords: [CareRecord] {
        allRecords.filter { $0.year == selectedYear && $0.month == selectedMonth }
    }

    var body: some View {
        List {
            // ── Year / Month Filter ──
            Section {
                HStack {
                

                    // Month picker
                    Menu {
                        ForEach(1...12, id: \.self) { m in
                            Button(months[m - 1]) { selectedMonth = m }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(months[selectedMonth - 1])
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                    }
                    
                    // Year picker
                    Menu {
                        ForEach(years, id: \.self) { year in
                            Button(String(year)) { selectedYear = year }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(String(selectedYear))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                    }

                    Spacer()
                }
                .toolbar(.hidden, for: .tabBar)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }

            // ── Care Records ──
            Section {
                if filteredRecords.isEmpty {
                    Text("No records for this month")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(filteredRecords) { record in
                        recordCard(record)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle("Care History")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, -30)
    }

    // MARK: - Record Card

    private func recordCard(_ record: CareRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            // Type + Date
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.type.label)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(record.type.color)
                    Text(record.detail)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(record.date)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            // Photo placeholder
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.10))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.green.opacity(0.3))
                )

            // Note (if present)
            if let note = record.note {
                Text("\"\(note)\"")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CareHistoryView()
    }
}
