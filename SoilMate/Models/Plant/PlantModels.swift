//
//  PlantModels.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

// MARK: - Plant Catalog (master data)

/// A plant species from the catalog. Matches PlantResponse.
struct Plant: Decodable, Identifiable {
    let id: Int64
    let name: String
    let scientificName: String?
    let wateringIntervalDays: Int?
    let wateringAmountMl: Int?
    let feedingIntervalDays: Int?
    let feedingType: String?
    let sunlightRequirement: String?  // "FULL_SUN", "PARTIAL", "LOW_LIGHT", etc.
    let imageUrl: String?
    let note: String?
}

// MARK: - User Plant (my garden)

/// A plant in the user's garden. Matches UserPlantDetailResponse.
struct UserPlantDetail: Decodable, Identifiable {
    let id: Int64
    let nickname: String?
    let location: String?
    let photoUrl: String?
    let notes: String?
    let lastWateredAt: String?
    let lastFedAt: String?
    let createdAt: String?

    // Info from the plant catalog
    let plantId: Int64?
    let plantName: String?
    let scientificName: String?
    let sunlightRequirement: String?
    let plantImageUrl: String?

    // Care schedule (custom values override plant defaults)
    let wateringIntervalDays: Int?
    let wateringAmountMl: Int?
    let feedingIntervalDays: Int?
    let feedingType: String?
    
    let potSize: String?
    let environment: String?

    // Next care dates (computed by backend)
    let nextWateringDate: String?
    let nextFeedingDate: String?

    // Recent care history
    let recentCareLogs: [CareLogItem]?
}

extension UserPlantDetail {
 
    var potSizeValue: PotSize { PotSize.from(potSize) }
    var environmentValue: GrowingEnvironment { GrowingEnvironment.from(environment) }
 
    /// Calculated watering amount for today.
    var calculatedWaterAmountMl: Int? {
        guard let base = wateringAmountMl else { return nil }
        return WateringCalculator.calculate(
            baseAmountMl: base,
            potSize: potSizeValue,
            environment: environmentValue
        )
    }
}

// MARK: - Requests

/// Add a new plant to my garden
struct AddUserPlantRequest: Encodable {
    var barcodeValue: String?
    var plantId: Int64?
    var nickname: String?
    var location: String?
    var notes: String?
    var wateringIntervalDays: Int?
    var wateringAmountMl: Int?
    var feedingIntervalDays: Int?
    var feedingType: String?
    var potSize: String?
    var environment: String?
}

/// Update an existing plant in my garden
struct UpdateUserPlantRequest: Encodable {
    var nickname: String?
    var location: String?
    var notes: String?
    var wateringIntervalDays: Int?
    var wateringAmountMl: Int?
    var feedingIntervalDays: Int?
    var feedingType: String?
    var potSize: String?
    var environment: String?
}
