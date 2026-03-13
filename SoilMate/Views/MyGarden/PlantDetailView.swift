//
//  PlantDetailView.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/7.
//

import SwiftUI

struct PlantDetailView: View {

    let userPlantId: Int64

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlantDetailViewModel
    @State private var showDeleteConfirm = false
    @State private var showEditPlant = false

    init(userPlantId: Int64) {
        self.userPlantId = userPlantId
        self._viewModel = State(initialValue: PlantDetailViewModel(userPlantId: userPlantId))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let _ = viewModel.plant {
                detailContent
            } else {
                Text(viewModel.errorMessage ?? "Plant not found")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Plant Detail Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showEditPlant = true
                    } label: {
                        Label("Edit Plant Information", systemImage: "square.and.pencil")
                            .foregroundStyle(.primary)
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Plant", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                } label: {
                    Image(systemName: "square.on.square")
                        .foregroundColor(.primary)
                }
                .tint(nil)
            }
        }
        .alert(
            "Do you want to delete it?",
            isPresented: $showDeleteConfirm
        ) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.deletePlant() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your plant \(viewModel.displayName) will be deleted permanently.")
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $showEditPlant) {
            EditPlantView(userPlantId: userPlantId)
        }
        // Dismiss after delete
        .onChange(of: viewModel.didDelete) { _, deleted in
            if deleted { dismiss() }
        }
        // Reload after editing
        .onChange(of: showEditPlant) { _, showing in
            if !showing { Task { await viewModel.load() } }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Detail Content

    private var detailContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Plant Photo
                plantPhoto
                    .padding(.horizontal)

                // MARK: Name
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.displayName)
                        .font(.system(size: 30, weight: .bold))

                    Text(viewModel.scientificLabel)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.horizontal)

                // MARK: Watering + Feeding
                HStack(alignment: .top, spacing: 12) {
                    wateringCard
                    feedingCard
                }
                .padding(.horizontal)

                // MARK: Info + History
                HStack(alignment: .top, spacing: 12) {

                    VStack(spacing: 12) {
                        infoCard(title: "Light", value: viewModel.sunlightText)
                        infoCard(title: "Environment", value: "Indoor · Medium Pot")  // hardcoded for now
                        infoCard(title: "Location", value: viewModel.locationText)
                    }

                    historyCard
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Plant Photo

    private var plantPhoto: some View {
        Group {
            if let urlStr = viewModel.plant?.plantImageUrl ?? viewModel.plant?.photoUrl,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    photoPlaceholder
                }
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                photoPlaceholder
                    .frame(width: 160, height: 160)
            }
        }
    }

    private var photoPlaceholder: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.green.opacity(0.12))
            .overlay(
                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green.opacity(0.4))
            )
    }

    // MARK: - Watering Card

    private var wateringCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Watering")
                .font(.system(size: 20, weight: .bold))

            Text("Water until it drains from the bottom")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Text(viewModel.wateringScheduleText)
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Spacer(minLength: 14)

            Text("Next:")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
            Text(viewModel.nextWateringDateText)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
            Spacer(minLength: 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    // MARK: - Feeding Card

    private var feedingCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Feeding")
                .font(.system(size: 20, weight: .bold))

            Text(viewModel.feedingScheduleText)
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Text(viewModel.feedingTypeText)
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Spacer(minLength: 30)

            Text("Next:")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
            Text(viewModel.nextFeedingDateText)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
            Spacer(minLength: 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    // MARK: - Info Card

    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    // MARK: - History Card

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(alignment: .top) {
                Text("History")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                NavigationLink {
                    CareHistoryView(userPlantId: userPlantId)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 30)
                }
                .buttonStyle(.glassProminent)
                .tint(.mint)
            }

            Spacer(minLength: 1)

            if viewModel.recentLogs.isEmpty {
                Text("No records yet")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(viewModel.recentLogs.prefix(3).enumerated()), id: \.element.id) { index, log in
                    historyItem(log)
                    if index < min(viewModel.recentLogs.count, 3) - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }

    private func historyItem(_ log: CareLogItem) -> some View {
        let color: Color = log.isWatering ? .blue : .orange
        let label = log.isWatering ? "Water:" : "Feed:"
        let dateText = DateHelper.displayDate(
            DateHelper.parseDateTime(log.performedAt) ?? Date()
        )

        return VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(dateText)
                .font(.system(size: 16))
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PlantDetailView(userPlantId: 1)
    }
}
