//
//  CalendarView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

// MARK: - Selectable item enum (task or log)

private enum CalendarItem: Identifiable, Equatable {
    case task(CareTaskItem)
    case log(CareLogItem)

    var id: String {
        switch self {
        case .task(let t): return "task-\(t.id)"
        case .log(let l): return "log-\(l.id)"
        }
    }

    var userPlantId: Int64? {
        switch self {
        case .task(let t): return t.userPlantId
        case .log(let l): return l.userPlantId
        }
    }

    static func == (lhs: CalendarItem, rhs: CalendarItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Calendar View

struct CalendarView: View {

    @State private var viewModel = CalendarViewModel()
    @State private var selectedItem: CalendarItem? = nil
    @State private var navigateToPlantId: Int64? = nil
    @Namespace private var namespace

    private let headerHeight: CGFloat = 48
    private let filters = ["All Tasks", "Watering", "Feeding"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    Spacer().frame(height: 16)

                    // Date picker
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker(
                            "Select Date",
                            selection: $viewModel.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(.mint)
                        .padding(12)
                        .glassEffect(.regular, in: .rect(cornerRadius: 36))
                        .padding(.horizontal)
                    }

                    // Filter tabs
                    filterTabs
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    // Content
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else {
                        contentSections
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .task {
                await viewModel.loadAll()
            }
            .sheet(item: $selectedItem) { item in
                Group {
                    switch item {
                    case .task(let task):
                        TaskDetailSheet(task: task, viewModel: viewModel, namespace: namespace) {
                            // Dismiss sheet then navigate
                            selectedItem = nil
                            navigateToPlantId = task.userPlantId
                        }
                    case .log(let log):
                        LogDetailSheet(log: log, viewModel: viewModel, namespace: namespace) {
                            selectedItem = nil
                            navigateToPlantId = log.userPlantId
                        }
                    }
                }
                .presentationDetents([.fraction(0.45)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
            }
            // Navigate to PlantDetailView after sheet dismisses
            .navigationDestination(item: $navigateToPlantId) { plantId in
                PlantDetailView(userPlantId: plantId)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Calendar")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                )
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 0)
        .frame(height: headerHeight, alignment: .center)
    }

    // MARK: - Filter Tabs

    private var filterTabs: some View {
        HStack(spacing: 10) {
            ForEach(0..<filters.count, id: \.self) { index in
                filterButton(for: index)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func filterButton(for index: Int) -> some View {
        let label = Text(filters[index])
            .font(.system(size: 14, weight: .medium))

        if viewModel.selectedFilter == index {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedFilter = index }
            } label: { label }
            .buttonStyle(.glassProminent)
            .tint(.mint)
        } else {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedFilter = index }
            } label: { label }
            .buttonStyle(.glass)
            .tint(.black)
        }
    }

    // MARK: - Content Sections (Tasks + Logs)

    private var contentSections: some View {
        VStack(alignment: .leading, spacing: 16) {
            let showWatering = viewModel.selectedFilter == 0 || viewModel.selectedFilter == 1
            let showFeeding = viewModel.selectedFilter == 0 || viewModel.selectedFilter == 2

            // Pending Tasks
            if showWatering && !viewModel.wateringTasks.isEmpty {
                taskSectionBlock(title: "WATERING", tasks: viewModel.wateringTasks)
            }
            if showFeeding && !viewModel.feedingTasks.isEmpty {
                taskSectionBlock(title: "FEEDING", tasks: viewModel.feedingTasks)
            }

            // Care Logs (completed records)
            if viewModel.hasLogs {
                let filteredLogs: [CareLogItem] = {
                    if showWatering && showFeeding { return viewModel.wateringLogs + viewModel.feedingLogs }
                    if showWatering { return viewModel.wateringLogs }
                    if showFeeding { return viewModel.feedingLogs }
                    return []
                }()

                if !filteredLogs.isEmpty {
                    logSectionBlock(title: "CARE RECORDS", logs: filteredLogs)
                }
            }

            // Empty state
            if !viewModel.hasTasks && !viewModel.hasLogs {
                Text("No tasks or records for this date")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }

            Spacer(minLength: 40)
        }
        .padding(.horizontal)
    }

    // MARK: - Task Section Block

    private func taskSectionBlock(title: String, tasks: [CareTaskItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.leading, 16)

            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    Button {
                        selectedItem = .task(task)
                    } label: {
                        taskRow(task)
                    }
                    .buttonStyle(.plain)

                    if index < tasks.count - 1 {
                        Divider().padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    private func taskRow(_ task: CareTaskItem) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(task.isWatering ? Color.blue : Color.orange)
                .frame(width: 4, height: 28)

            Text(task.plantNickname ?? "Plant")
                .font(.system(size: 16))

            Text("·")
                .foregroundColor(.secondary)

            Text(viewModel.taskDetail(task))
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    // MARK: - Log Section Block

    private func logSectionBlock(title: String, logs: [CareLogItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.leading, 16)

            VStack(spacing: 0) {
                ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                    Button {
                        selectedItem = .log(log)
                    } label: {
                        logRow(log)
                    }
                    .buttonStyle(.plain)

                    if index < logs.count - 1 {
                        Divider().padding(.horizontal, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    private func logRow(_ log: CareLogItem) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(log.isWatering ? Color.blue : Color.orange)
                .frame(width: 4, height: 28)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.green)

            Text(log.plantNickname ?? "Plant")
                .font(.system(size: 16))

            Text("·")
                .foregroundColor(.secondary)

            Text(viewModel.logDetail(log))
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Task Detail Sheet

private struct TaskDetailSheet: View {
    let task: CareTaskItem
    let viewModel: CalendarViewModel
    let namespace: Namespace.ID
    let onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Spacer().frame(height: 24)

            // Plant info — no background, wider
            HStack(spacing: 12) {
                sheetPlantImage(url: task.plantImageUrl)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.plantNickname ?? "Plant")
                        .font(.system(size: 17, weight: .semibold))

                    Text(task.plantLocation ?? "—")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    onDetailTap()
                } label: {
                    HStack(spacing: 4) {
                        Text("Detail")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)

            // Task detail card — white background, wider
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(task.careTypeDisplay)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(task.isWatering ? .blue : .orange)

                    Spacer()

                    Text(task.scheduledDate)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Text(taskAmount)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text("Status: \(task.status)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .italic()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.8))
            )
            .padding(.horizontal, 4)

            // Action buttons
            HStack(spacing: 12) {
                Button {
                    Task { await viewModel.completeTask(task) }
                } label: {
                    Text("Complete")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)

                Button {
                    Task { await viewModel.skipTask(task) }
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
        .ignoresSafeArea(edges: .bottom)
        .glassEffectID("detailCard", in: namespace)
    }

    private var taskAmount: String {
        if task.isWatering {
            return task.waterAmountMl.map { "\($0) ml" } ?? "Water"
        } else {
            return task.feedingType ?? "Fertilizer"
        }
    }
}

// MARK: - Log Detail Sheet

private struct LogDetailSheet: View {
    let log: CareLogItem
    let viewModel: CalendarViewModel
    let namespace: Namespace.ID
    let onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Spacer().frame(height: 24)

            // Plant info — no background, wider
            HStack(spacing: 12) {
                sheetPlantImage(url: log.plantImageUrl)

                VStack(alignment: .leading, spacing: 2) {
                    Text(log.plantNickname ?? "Plant")
                        .font(.system(size: 17, weight: .semibold))

                    Text(log.plantLocation ?? "—")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    onDetailTap()
                } label: {
                    HStack(spacing: 4) {
                        Text("Detail")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)

            // Log detail card — white background, wider
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(log.careTypeDisplay)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(log.isWatering ? .blue : .orange)

                    Spacer()

                    Text(viewModel.logDate(log))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Text(viewModel.logDetail(log))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                // Photo (placeholder for now, can load from log.photoUrl later)
                if let photoUrl = log.photoUrl, let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        photoPlaceholder
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    photoPlaceholder
                }

                // Notes
                if let notes = log.notes, !notes.isEmpty {
                    Text("\"\(notes)\"")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.8))
            )
            .padding(.horizontal, 4)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
        .ignoresSafeArea(edges: .bottom)
        .glassEffectID("logDetailCard", in: namespace)
    }

    private var photoPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 32))
                    .foregroundColor(.green.opacity(0.35))
            )
    }
}

// MARK: - Shared plant image for sheets

private func sheetPlantImage(url: String?) -> some View {
    Group {
        if let urlStr = url, let imageUrl = URL(string: urlStr) {
            AsyncImage(url: imageUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                sheetPlantImagePlaceholder
            }
        } else {
            sheetPlantImagePlaceholder
        }
    }
    .frame(width: 50, height: 50)
    .clipShape(RoundedRectangle(cornerRadius: 12))
}

private var sheetPlantImagePlaceholder: some View {
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.green.opacity(0.12))
        .overlay(
            Image(systemName: "leaf.fill")
                .font(.system(size: 20))
                .foregroundColor(.green.opacity(0.4))
        )
}

// Make CareTaskItem work with sheet(item:)
extension CareTaskItem: Equatable {
    public static func == (lhs: CareTaskItem, rhs: CareTaskItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Make Int64 work with navigationDestination(item:)
extension Int64: @retroactive Identifiable {
    public var id: Int64 { self }
}

#Preview {
    CalendarView()
}
