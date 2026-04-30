//
//  TaskResultView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/7.
//

import SwiftUI
 
struct TaskResultView: View {
 
    let task: PortableTask
    let action: WatchTaskAction
 
    @Environment(\.dismiss) private var dismiss
 
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Spacer().frame(height: 16)
 
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(iconForegroundColor)
                    )
 
                Text(titleText)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
 
                Text(task.plantNickname ?? "Plant")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
 
                Text(task.detailText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
 
                if let location = task.plantLocation {
                    Text(location)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
 
                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 4)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
    }
 
    // MARK: - Computed Properties
 
    private var isCompleted: Bool {
        action == .complete
    }
 
    private var titleText: String {
        if isCompleted {
            return task.isWatering ? "Watered!" : "Fed!"
        } else {
            return "Care Task Skipped"
        }
    }
 
    private var iconName: String {
        isCompleted ? "checkmark" : "exclamationmark"
    }
 
    private var iconBackgroundColor: Color {
        isCompleted ? Color.mint.opacity(0.25) : Color.orange.opacity(0.25)
    }
 
    private var iconForegroundColor: Color {
        isCompleted ? .mint : .orange
    }
}
 
#Preview("Completed") {
    NavigationStack {
        TaskResultView(
            task: PortableTask(
                id: 1,
                careType: "WATER",
                scheduledDate: "2026-04-05",
                status: "COMPLETED",
                daysUntil: 0,
                waterAmountMl: 200,
                feedingType: nil,
                plantNickname: "MySnakePlant",
                plantLocation: "Living Room"
            ),
            action: .complete
        )
    }
}
 
#Preview("Skipped") {
    NavigationStack {
        TaskResultView(
            task: PortableTask(
                id: 2,
                careType: "WATER",
                scheduledDate: "2026-04-05",
                status: "SKIPPED",
                daysUntil: 0,
                waterAmountMl: 200,
                feedingType: nil,
                plantNickname: "MySnakePlant",
                plantLocation: "Living Room"
            ),
            action: .skip
        )
    }
}

