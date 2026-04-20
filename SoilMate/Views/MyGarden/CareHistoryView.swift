//
//  CareHistoryView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/8.
//

import SwiftUI

struct CareHistoryView: View {

    let userPlantId: Int64

    @State private var viewModel: CareHistoryViewModel

    private let months = Calendar.current.monthSymbols
    private let years = Array(2024...2026)

    init(userPlantId: Int64) {
        self.userPlantId = userPlantId
        self._viewModel = State(initialValue: CareHistoryViewModel(userPlantId: userPlantId))
    }

    var body: some View {
        List {
            // MARK: - Year / Month Filter
            Section {
                HStack {
                    // Month picker
                    Menu {
                        ForEach(1...12, id: \.self) { m in
                            Button(months[m - 1]) { viewModel.selectedMonth = m }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(months[viewModel.selectedMonth - 1])
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
                            Button(String(year)) { viewModel.selectedYear = year }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(String(viewModel.selectedYear))
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

            // MARK: - Care Records
            Section {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if viewModel.logs.isEmpty {
                    Text("No records for this month")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(viewModel.logs) { log in
                        recordCard(log)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle("Care History")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, -30)
        .task {
            await viewModel.loadLogs()
        }
    }

    // MARK: - Record Card

    private func recordCard(_ log: CareLogItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Type + Date
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.isWatering ? "Watering" : "Feeding")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(log.isWatering ? .blue : .orange)

                    Text(viewModel.detailText(log))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(viewModel.displayDate(log))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            // DEMO: local image for all care records
            Image("IMG_2415")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // Note
            if let note = log.notes, !note.isEmpty {
                Text("\"\(note)\"")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CareHistoryView(userPlantId: 1)
    }
}
