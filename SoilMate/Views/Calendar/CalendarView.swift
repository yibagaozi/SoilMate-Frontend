//
//  CalendarView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

private struct StaticTask: Identifiable, Equatable {
    let id = UUID()
    let plantName: String
    let scientificName: String
    let detail: String
    let amount: String
    let date: String
    let note: String
    let isWatering: Bool

    static func == (lhs: StaticTask, rhs: StaticTask) -> Bool {
        lhs.id == rhs.id
    }
}

private let wateringTasks = [
    StaticTask(plantName: "Snake Plant", scientificName: "Sansevieria trifasciata",
               detail: "200ml", amount: "200 ml", date: "Apr 20, 2025",
               note: "Leaves looking healthy after watering", isWatering: true),
    StaticTask(plantName: "Succulent", scientificName: "Echeveria elegans",
               detail: "160ml", amount: "160 ml", date: "Apr 20, 2025",
               note: "Soil was very dry before watering", isWatering: true),
]

private let feedingTasks = [
    StaticTask(plantName: "Monstera", scientificName: "Monstera deliciosa",
               detail: "General fertilizer", amount: "General fertilizer", date: "Apr 20, 2025",
               note: "Applied half-strength liquid fertilizer", isWatering: false),
]

// MARK: - Calendar View

struct CalendarView: View {

    private let headerHeight: CGFloat = 48

    @State private var selectedDate = Date()
    @State private var selectedFilter = 0
    @State private var selectedTask: StaticTask? = nil
    @Namespace private var namespace

    private let filters = ["All Tasks", "Watering", "Feeding"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    header
                    
                    Spacer().frame(height:16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(.mint)
                        .padding(12)
                        .glassEffect(.regular, in: .rect(cornerRadius: 36))
                        .padding(.horizontal)
                    }

                    filterTabs
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    taskSections
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(item: $selectedTask) { task in
                TaskDetailSheet(task: task, namespace: namespace)
                    .presentationDetents([.fraction(0.45)])
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

        if selectedFilter == index {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = index }
            } label: { label }
            .buttonStyle(.glassProminent)
            .tint(.mint)
        } else {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = index }
            } label: { label }
            .buttonStyle(.glass)
            .tint(.black)
        }
    }

    // MARK: - Task Sections

    private var taskSections: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedFilter == 0 || selectedFilter == 1 {
                sectionBlock(title: "WATERING", tasks: wateringTasks)
            }
            if selectedFilter == 0 || selectedFilter == 2 {
                sectionBlock(title: "FEEDING", tasks: feedingTasks)
            }
            Spacer(minLength: 40)
        }
        .padding(.horizontal)
    }

    private func sectionBlock(title: String, tasks: [StaticTask]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.leading, 16)

            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    Button {
                        withAnimation(.spring(duration: 0.25, bounce: 0.15)) {
                            selectedTask = task
                        }
                    } label: {
                        taskRow(task)
                    }
                    .buttonStyle(.plain)

                    if index < tasks.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    private func taskRow(_ task: StaticTask) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(task.isWatering ? Color.blue : Color.orange)
                .frame(width: 4, height: 28)

            Text(task.plantName)
                .font(.system(size: 16))

            Text("·")
                .foregroundColor(.secondary)

            Text(task.detail)
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
    let task: StaticTask
    let namespace: Namespace.ID

    var body: some View {
        ZStack {

            VStack(alignment: .leading, spacing: 12) {

                Spacer().frame(height: 24)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.12))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green.opacity(0.4))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.plantName)
                                .font(.system(size: 17, weight: .semibold))
                            Text(task.scientificName)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .italic()
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("Detail")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
                }
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white.opacity(0.8))
                )
                .padding(.horizontal, 12)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(task.isWatering ? "Watering" : "Feeding")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(task.isWatering ? .blue : .orange)

                        Spacer()

                        Text(task.date)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    Text(task.amount)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                        )
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.green.opacity(0.35))
                        )

                    Text("\"\(task.note)\"")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.white.opacity(0.8))
                    )
                    .padding(.horizontal, 12)

                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
            }
        .ignoresSafeArea(edges: .bottom)
        .glassEffectID("detailCard", in: namespace)
    }
}

#Preview {
    CalendarView()
}
