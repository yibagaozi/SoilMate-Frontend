//
//  MyGardenViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation
import SwiftUI

@Observable
final class MyGardenViewModel {

    // MARK: - State

    /// All plants in the user's garden
    var plants: [UserPlantDetail] = []

    /// true when there are no plants
    var isEmpty: Bool { plants.isEmpty }

    var isLoading = false
    var errorMessage: String?
    
    struct CareStatus {
        let text: String
        let color: Color
    }

    // MARK: - Load

    /// Call this in .task { } when MyGardenView appears
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            plants = try await UserPlantService.listMyPlants()
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load garden"
        }

        isLoading = false
    }

    // MARK: - Delete

    /// Delete a plant from the garden
    func deletePlant(id: Int64) async {
        // Look up the local photo before deletion so we can clean it up.
        let photoToDelete = plants.first(where: { $0.id == id })?.photoUrl

        do {
            try await UserPlantService.deletePlant(id: id)
            plants.removeAll { $0.id == id }

            // Remove the local photo file once the backend has confirmed deletion.
            if let f = photoToDelete, PhotoStorage.isLocal(f) {
                PhotoStorage.delete(f)
            }
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to delete plant"
        }
    }

    // MARK: - Helpers

    /// "Tomorrow", "Today", "In 6 Days", etc. based on next watering date
    func nextCareStatus(_ plant: UserPlantDetail) -> CareStatus {
        let waterDate = DateHelper.parseDate(plant.nextWateringDate)
        let feedDate = DateHelper.parseDate(plant.nextFeedingDate)

        let isWaterSooner: Bool
        let dateString: String?

        switch (waterDate, feedDate) {
        case let (w?, f?):
            isWaterSooner = w <= f
            dateString = isWaterSooner ? plant.nextWateringDate : plant.nextFeedingDate
        case (_, nil):
            isWaterSooner = true
            dateString = plant.nextWateringDate
        case (nil, _):
            isWaterSooner = false
            dateString = plant.nextFeedingDate
        }

        let text = DateHelper.relativeDayText(from: dateString)

        let color: Color = switch text {
        case "Overdue":  .red
        case "Today":    .mint
        case "Tomorrow": .purple
        default:         isWaterSooner ? .blue : .orange
        }

        return CareStatus(text: text, color: color)
    }
}
