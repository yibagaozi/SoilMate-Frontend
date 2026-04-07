//
//  EditPlantViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation

@Observable
final class EditPlantViewModel {

    // MARK: - Form Fields

    var officialName = ""
    var commonName = ""
    var nickname = ""
    var location = ""
    var environment: GrowingEnvironment = .indoor
    var potSize: PotSize = .medium

    var waterFrequency = 14
    var waterAmount = 200
    var feedingFrequency = 60
    var feedingType = "General fertilizer"
    var lightRequirement = "Flexible"

    var enableNotification = true

    // MARK: - State

    var isSaving = false
    var errorMessage: String?

    /// Set to true after save succeeds. View should dismiss.
    var didSave = false

    /// The plant we are editing
    let userPlantId: Int64

    init(userPlantId: Int64) {
        self.userPlantId = userPlantId
    }
    
    // Live-calculated
    var calculatedAmountMl: Int {
        WateringCalculator.calculate(
            baseAmountMl: waterAmount,
            potSize: potSize,
            environment: environment
        )
    }
 
    var calculationTags: [String] {
        WateringCalculator.tags(potSize: potSize, environment: environment)
    }
 

    // MARK: - Load Existing Data

    /// Fill the form with the plant's current values.
    /// Call this in .task { } when EditPlantView appears.
    func load() async {
        do {
            let plant = try await UserPlantService.getDetail(id: userPlantId)
            fillForm(from: plant)
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load plant"
        }
    }

    /// You can also fill from a plant you already have (no network call needed)
    func fillForm(from plant: UserPlantDetail) {
        officialName = plant.scientificName ?? ""
        commonName = plant.plantName ?? ""
        nickname = plant.nickname ?? ""
        location = plant.location ?? ""
        potSize = plant.potSizeValue
        environment = plant.environmentValue

        waterFrequency = plant.wateringIntervalDays ?? 14
        waterAmount = plant.wateringAmountMl ?? 200
        feedingFrequency = plant.feedingIntervalDays ?? 60
        feedingType = plant.feedingType ?? "General fertilizer"

        if let sun = plant.sunlightRequirement {
            lightRequirement = sun
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
    }

    // MARK: - Save

    /// Save changes to the server
    func save() async {
        isSaving = true
        errorMessage = nil

        let request = UpdateUserPlantRequest(
            nickname: nickname.isEmpty ? nil : nickname,
            location: location.isEmpty ? nil : location,
            notes: nil,
            wateringIntervalDays: waterFrequency,
            wateringAmountMl: waterAmount,
            feedingIntervalDays: feedingFrequency,
            feedingType: feedingType,
            potSize: potSize.rawValue,
            environment: environment.rawValue
        )

        do {
            try await UserPlantService.updatePlant(id: userPlantId, request)
            didSave = true
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to save changes"
        }

        isSaving = false
    }
}
