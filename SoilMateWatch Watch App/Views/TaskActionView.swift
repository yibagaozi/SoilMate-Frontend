//
//  TaskActionView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import SwiftUI
 
struct TaskActionView: View {
 
    let task: PortableTask
 
    @Environment(WatchTaskViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
 
    @State private var navigateToResult = false
    @State private var actionTaken: WatchTaskAction?
 
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Spacer().frame(height: 4)
 
                Text(task.careTypeDisplay)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(task.isWatering ? .blue : .orange)
 
                Text(task.plantNickname ?? "Plant")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
 
                Text(task.detailText)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
 
                if let location = task.plantLocation {
                    Text(location)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
 
                Spacer().frame(height: 8)
 
                Button {
                    actionTaken = .complete
                    viewModel.completeTask(task)
                    navigateToResult = true
                } label: {
                    Text("Finish")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
 
                Button {
                    actionTaken = .skip
                    viewModel.skipTask(task)
                    navigateToResult = true
                } label: {
                    Text("Skip")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToResult) {
            if let action = actionTaken {
                TaskResultView(task: task, action: action)
            }
        }
    }
}
 
#Preview {
    NavigationStack {
        TaskActionView(
            task: PortableTask(
                id: 1,
                careType: "WATER",
                scheduledDate: "2026-04-05",
                status: "PENDING",
                daysUntil: 0,
                waterAmountMl: 200,
                feedingType: nil,
                plantNickname: "MySnakePlant",
                plantLocation: "Living Room"
            )
        )
        .environment(WatchTaskViewModel.shared)
    }
}
