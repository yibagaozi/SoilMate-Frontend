//
//  CalendarView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

struct CalendarView: View {

    @State private var viewModel = CalendarViewModel()
    @State private var selectedTask: CareTaskItem? = nil
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

                    // Task list
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else {
                        taskSections
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .task {
                await viewModel.loadTasks()
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailSheet(task: task, viewModel: viewModel, namespace: namespace)
                    .presentationDetents([.fraction(0.35)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.clear)
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

    // MARK: - Task Sections

    private var taskSections: some View {
        VStack(alignment: .leading, spacing: 16) {
            let showWatering = viewModel.selectedFilter == 0 || viewModel.selectedFilter == 1
            let showFeeding = viewModel.selectedFilter == 0 || viewModel.selectedFilter == 2

            if showWatering && !viewModel.wateringTasks.isEmpty {
                sectionBlock(title: "WATERING", tasks: viewModel.wateringTasks)
            }
            if showFeeding && !viewModel.feedingTasks.isEmpty {
                sectionBlock(title: "FEEDING", tasks: viewModel.feedingTasks)
            }

            // Empty state
            if (showWatering && viewModel.wateringTasks.isEmpty) &&
               (showFeeding && viewModel.feedingTasks.isEmpty) {
                Text("No tasks for this date")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }

            Spacer(minLength: 40)
        }
        .padding(.horizontal)
    }

    private func sectionBlock(title: String, tasks: [CareTaskItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.leading, 16)

            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    Button {
                        selectedTask = task
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
}

// MARK: - Task Detail Sheet

private struct TaskDetailSheet: View {
    let task: CareTaskItem
    let viewModel: CalendarViewModel
    let namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer().frame(height: 24)

            // Plant info
            HStack(spacing: 12) {
                // Placeholder image
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green.opacity(0.4))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.plantNickname ?? "Plant")
                        .font(.system(size: 17, weight: .semibold))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.8))
            )
            .padding(.horizontal, 12)

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
            .padding(.horizontal, 24)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
        .ignoresSafeArea(edges: .bottom)
        .glassEffectID("detailCard", in: namespace)
    }
}

// Make CareTaskItem work with .sheet(item:)
extension CareTaskItem: Equatable {
    public static func == (lhs: CareTaskItem, rhs: CareTaskItem) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    CalendarView()
}
