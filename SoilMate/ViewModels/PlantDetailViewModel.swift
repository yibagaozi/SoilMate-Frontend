//
//  PlantDetailViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation

@Observable
final class PlantDetailViewModel {

    // MARK: - State

    /// The plant's full detail
    var plant: UserPlantDetail?

    /// Recent care logs for this plant
    var recentLogs: [CareLogItem] { plant?.recentCareLogs ?? [] }

    var isLoading = false
    var errorMessage: String?

    /// Set to true after a successful delete (view should dismiss)
    var didDelete = false

    /// The plant ID to load
    let userPlantId: Int64

    init(userPlantId: Int64) {
        self.userPlantId = userPlantId
    }

    // MARK: - Load

    /// Call this in .task { } when PlantDetailView appears
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            plant = try await UserPlantService.getDetail(id: userPlantId)
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load plant detail"
        }

        isLoading = false
    }

    // MARK: - Delete

    /// Delete this plant. Sets didDelete = true on success.
    func deletePlant() async {
        do {
            try await UserPlantService.deletePlant(id: userPlantId)
            didDelete = true
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to delete plant"
        }
    }

    // MARK: - Display Helpers

    var displayName: String {
        plant?.nickname ?? plant?.plantName ?? "Plant"
    }

    var scientificLabel: String {
        let common = plant?.plantName ?? ""
        let scientific = plant?.scientificName ?? ""
        if common.isEmpty && scientific.isEmpty { return "" }
        if scientific.isEmpty { return common }
        return "\(common) · \(scientific)"
    }

    var wateringScheduleText: String {
        let days = plant?.wateringIntervalDays ?? 0
        let amount = plant?.wateringAmountMl ?? 0
        return "Every \(days) Days · \(amount)ml"
    }

    var feedingScheduleText: String {
        let days = plant?.feedingIntervalDays ?? 0
        return "Every \(days) Days"
    }

    var feedingTypeText: String {
        plant?.feedingType ?? "General fertilizer"
    }

    var nextWateringText: String {
        DateHelper.relativeDayText(from: plant?.nextWateringDate)
    }

    var nextWateringDateText: String {
        DateHelper.displayDate(plant?.nextWateringDate)
    }

    var nextFeedingDateText: String {
        DateHelper.displayDate(plant?.nextFeedingDate)
    }

    var sunlightText: String {
        // Convert "FULL_SUN" to "Full Sun" etc.
        plant?.sunlightRequirement?
            .replacingOccurrences(of: "_", with: " ")
            .capitalized ?? "Flexible"
    }

    var locationText: String {
        plant?.location ?? "—"
    }
}
