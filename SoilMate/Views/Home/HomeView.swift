//
//  HomeView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()

    private let headerHeight: CGFloat = 48

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    // MARK: - Today's Tasks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Tasks")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                        } else if let task = viewModel.todayTask {
                            todayCard(task)
                        } else {
                            emptyTodayCard
                        }
                    }

                    // MARK: - Up Next
                    if !viewModel.upcomingTasks.isEmpty {
                        upNextSection
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .task {
                await viewModel.load()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Home")
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
        .padding(.top, 0)
        .padding(.bottom, 16)
        .frame(height: headerHeight, alignment: .center)
    }

    // MARK: - Today Card (real data)

    private func todayCard(_ task: CareTaskItem) -> some View {
        // Plant image or placeholder
        ZStack(alignment: .bottom) {
            // Background image
            plantImage(url: task.plantImageUrl)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 30))

            // Info overlay at bottom
            VStack(alignment: .leading, spacing: 8) {
                Text(task.plantNickname ?? "Plant")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(task.isWatering ? "Watering needed" : "Feeding needed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.isWatering ? "Watering needed" : "Feeding needed")
                            .font(.body)
                            .fontWeight(.semibold)

                        Text(viewModel.taskDetailText(task))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        Task { await viewModel.completeTask(task) }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .frame(width: 30, height: 40)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.mint)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .glassEffect(
                .regular,
                in: .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 30,
                    bottomTrailingRadius: 30,
                    topTrailingRadius: 0
                )
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Empty Today Card

    private var emptyTodayCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.mint.opacity(0.5))

            Text("All done for today!")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal)
    }

    // MARK: - Up Next Section

    private var upNextSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Up Next")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.top, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                GlassEffectContainer(spacing: 16) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.upcomingTasks) { task in
                            upNextCard(task)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func upNextCard(_ task: CareTaskItem) -> some View {
        let statusText = viewModel.statusText(task)
        let statusColor = statusColorFor(statusText)

        return VStack(alignment: .leading, spacing: 8) {
            plantImage(url: task.plantImageUrl)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(task.plantNickname ?? "Plant")
                .font(.headline)

            Text(task.isWatering ? "Watering" : "Feeding")
                .font(.caption)
                .foregroundColor(.gray)

            Text(statusText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
        }
        .padding()
        .frame(width: 180, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }

    // MARK: - Helpers

    /// Load image from URL or show placeholder
    private func plantImage(url: String?) -> some View {
        Group {
            if let url, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    leafPlaceholder
                }
            } else {
                leafPlaceholder
            }
        }
    }

    private var leafPlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.green.opacity(0.12))
            .overlay(
                Image(systemName: "leaf.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green.opacity(0.4))
            )
    }

    /// Pick color based on status text
    private func statusColorFor(_ text: String) -> Color {
        switch text {
        case "Overdue": return .red
        case "Today":   return .blue
        case "Tomorrow": return .orange
        default:         return .mint
        }
    }
}

#Preview {
    HomeView()
}
