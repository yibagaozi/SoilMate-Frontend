//
//  TaskListView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import SwiftUI
 
struct TaskListView: View {
 
    @Environment(WatchTaskViewModel.self) private var viewModel
 
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.isEmpty {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("Care Tasks")
        }
    }
 
    // MARK: - Task List
 
    private var taskList: some View {
        List {
            if viewModel.hasTodayTasks {
                Section {
                    ForEach(viewModel.todayTasks) { task in
                        NavigationLink {
                            TaskActionView(task: task)
                        } label: {
                            TaskRow(task: task, isToday: true)
                        }
                    }
                } header: {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
 
            if viewModel.hasUpcomingTasks {
                Section {
                    ForEach(viewModel.upcomingTasks) { task in
                        NavigationLink {
                            TaskActionView(task: task)
                        } label: {
                            TaskRow(task: task, isToday: false)
                        }
                    }
                } header: {
                    Text("Up Next")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.carousel)
    }
 
    // MARK: - Empty State
 
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 36))
                .foregroundColor(.mint)
 
            Text("All clear")
                .font(.headline)
 
            Text("No tasks for now")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
 
// MARK: - Task Row
 
private struct TaskRow: View {
    let task: PortableTask
    let isToday: Bool
 
    @Environment(WatchTaskViewModel.self) private var viewModel
 
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.careTypeDisplay)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(task.isWatering ? .blue : .orange)
 
            Text(task.plantNickname ?? "Plant")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
 
            Text(task.detailText)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
 
            if !isToday {
                Text(viewModel.relativeDayText(for: task))
                    .font(.system(size: 12))
                    .foregroundColor(.mint)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}
 
#Preview {
    TaskListView()
        .environment(WatchTaskViewModel.shared)
}
