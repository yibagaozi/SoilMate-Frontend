//
//  HomeView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/6.
//

import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var selectedTask: CareTaskItem? = nil
    @Namespace private var namespace

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
            .sheet(item: $selectedTask) { task in
                HomeTaskSheet(
                    task: task,
                    viewModel: viewModel,
                    namespace: namespace
                ) {
                    selectedTask = nil
                }
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
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

    // MARK: - Today Card

    private func todayCard(_ task: CareTaskItem) -> some View {
        ZStack(alignment: .bottom) {
            Image(DemoPlantImage.name(for: task.userPlantId))
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 30))

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
                        selectedTask = task
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
            Image(DemoPlantImage.name(for: task.userPlantId))
                .resizable()
                .scaledToFill()
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

    private func statusColorFor(_ text: String) -> Color {
        switch text {
        case "Overdue": return .red
        case "Today":   return .blue
        case "Tomorrow": return .orange
        default:         return .mint
        }
    }
}

// MARK: - Home Task Sheet

private struct HomeTaskSheet: View {

    let task: CareTaskItem
    let viewModel: HomeViewModel
    let namespace: Namespace.ID
    let onDismiss: () -> Void

    @State private var adjustedAmount: Double
    @State private var isActioning = false

    private let sliderMin: Double = 50
    private let sliderMax: Double = 500
    private let sliderStep: Double = 10

    init(task: CareTaskItem, viewModel: HomeViewModel, namespace: Namespace.ID, onDismiss: @escaping () -> Void) {
        self.task = task
        self.viewModel = viewModel
        self.namespace = namespace
        self.onDismiss = onDismiss
        let initial = Double(task.displayedWaterAmountMl ?? task.waterAmountMl ?? 200)
        self._adjustedAmount = State(initialValue: initial)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Spacer().frame(height: 24)

            // MARK: Plant Info Row
            HStack(spacing: 12) {
                Image(DemoPlantImage.name(for: task.userPlantId))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.plantNickname ?? "Plant")
                        .font(.system(size: 17, weight: .semibold))
                    Text(task.plantLocation ?? "—")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
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
            .padding(.horizontal, 8)

            // MARK: Detail Card
            VStack(alignment: .leading, spacing: 14) {

                // Title row
                HStack(alignment: .firstTextBaseline) {
                    Text(task.careTypeDisplay)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(task.isWatering ? .blue : .orange)

                    Spacer()
                }

                if task.isWatering {
                    // Suggested amount subtitle
                    Text("Suggested amount: \(task.displayedWaterAmountMl ?? 0) ml · Today")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Divider()

                    // Instructions
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Instructions")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Water thoroughly until it drains from the bottom.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    // Amount for Today
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Amount for Today")
                            .font(.system(size: 15, weight: .semibold))

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(Int(adjustedAmount))")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.mint)
                                .contentTransition(.numericText())
                                .animation(.snappy, value: Int(adjustedAmount))
                            Text("ml")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }

                    // Slider
                    HStack(spacing: 8) {
                        Text("\(Int(sliderMin))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("ml")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)

                        Slider(
                            value: $adjustedAmount,
                            in: sliderMin...sliderMax,
                            step: sliderStep
                        )
                        .tint(.mint)

                        Text("\(Int(sliderMax))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("ml")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    // Tags
                    let tags = WateringCalculator.tags(
                        potSize: PotSize.from(task.potSize),
                        environment: GrowingEnvironment.from(task.environment)
                    )
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            tagView(tag)
                        }
                    }

                } else {
                    // Feeding task — simpler display
                    Text(task.feedingType ?? "General fertilizer")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text("Scheduled for today")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.8))
            )
            .padding(.horizontal, 4)

            // MARK: Action Buttons
            HStack(spacing: 12) {
                Button {
                    guard !isActioning else { return }
                    isActioning = true
                    Task {
                        await viewModel.skipTask(task)
                        onDismiss()
                    }
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .buttonStyle(.bordered)
                .disabled(isActioning)

                Button {
                    guard !isActioning else { return }
                    isActioning = true
                    Task {
                        let amount = task.isWatering ? Int(adjustedAmount) : nil
                        await viewModel.completeTask(task, actualAmountMl: amount)
                        onDismiss()
                    }
                } label: {
                    Text("Finish")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
                .disabled(isActioning)
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
        .ignoresSafeArea(edges: .bottom)
        .glassEffectID("homeTaskCard", in: namespace)
    }

    // MARK: - Tag View

    private func tagView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Make CareTaskItem work with sheet(item:)

extension CareTaskItem: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    HomeView()
}
