//
//  MyGardenViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation

@Observable
final class MyGardenViewModel {

    // MARK: - State

    /// All plants in the user's garden
    var plants: [UserPlantDetail] = []

    /// true when there are no plants
    var isEmpty: Bool { plants.isEmpty }

    var isLoading = false
    var errorMessage: String?

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
        do {
            try await UserPlantService.deletePlant(id: id)
            plants.removeAll { $0.id == id }
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to delete plant"
        }
    }

    // MARK: - Helpers

    /// "Tomorrow", "Today", "In 6 Days", etc. based on next watering date
    func wateringStatus(_ plant: UserPlantDetail) -> String {
        DateHelper.relativeDayText(from: plant.nextWateringDate)
    }
}
