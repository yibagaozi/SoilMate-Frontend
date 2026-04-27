//
//  AddPlantViewModel.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/3/7.
//

import Foundation
import UIKit

@Observable
final class AddPlantViewModel {

    // MARK: - Scanned Plant Info (from catalog)

    /// The plant found after scanning barcode
    var scannedPlant: Plant?

    /// The raw barcode string from VisionKit
    var scannedBarcodeValue: String?

    /// true if we found a plant from the barcode
    var hasPlant: Bool { scannedPlant != nil }

    // MARK: - Form Fields (user can customize)

    var nickname = ""
    var location = ""
    var notes = ""
    var environment: GrowingEnvironment = .indoor
    var potSize: PotSize = .medium

    var waterFrequency = 14
    var waterAmount = 200
    var feedingFrequency = 60
    var feedingType = "General fertilizer"
    var lightRequirement = "Flexible"

    var enableNotification = true

    // MARK: - Photo

    /// Image picked by the user. Saved to disk on `addToGarden()`.
    var selectedImage: UIImage?

    // MARK: - State

    var isScanning = false
    var isAdding = false
    var errorMessage: String?

    /// Set to true after plant is added. View should dismiss.
    var didAddPlant = false

    /// The ID of the newly added user plant
    var newPlantId: Int64?
    
    // Live-calculated amount
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

    // MARK: - Barcode Validation

    /// Validate barcode format: PLT-XXXXX-XX
    /// where XXXXX is 5 digits, XX is 2 alphanumeric characters
    private func isValidBarcode(_ value: String) -> Bool {
        let pattern = #"^PLT-\d{5}-[A-Za-z0-9]{2}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - Barcode Scan

    /// Called when the barcode scanner reads a code.
    /// Validates format, looks up the plant, and fills in default values.
    func onBarcodeScanned(_ barcodeValue: String) async {
        guard isValidBarcode(barcodeValue) else {
            errorMessage = "Invalid barcode format. Expected: PLT-XXXXX-XX"
            return
        }

        scannedBarcodeValue = barcodeValue
        isScanning = true
        errorMessage = nil

        do {
            let plant = try await PlantService.getPlantByBarcode(barcodeValue)
            self.scannedPlant = plant
            fillDefaults(from: plant)
        } catch ApiError.notFound {
            errorMessage = "Plant not found for this barcode"
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to look up barcode"
        }

        isScanning = false
    }

    /// Look up a plant by ID instead of barcode
    func lookupPlant(id: Int64) async {
        isScanning = true
        errorMessage = nil

        do {
            let plant = try await PlantService.getPlant(id: id)
            self.scannedPlant = plant
            fillDefaults(from: plant)
        } catch let error as ApiError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to look up plant"
        }

        isScanning = false
    }

    // MARK: - Add to Garden

    /// Submit the form and add plant to the user's garden
    func addToGarden() async {
        guard let plant = scannedPlant else {
            errorMessage = "Please scan a barcode first"
            return
        }

        isAdding = true
        errorMessage = nil

        // Save photo to local disk first (if any). Only the filename
        // is sent to the backend.
        var photoFilename: String?
        if let img = selectedImage {
            photoFilename = PhotoStorage.save(img)
        }

        let request = AddUserPlantRequest(
            barcodeValue: scannedBarcodeValue,
            plantId: plant.id,
            nickname: nickname.isEmpty ? nil : nickname,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            wateringIntervalDays: waterFrequency,
            wateringAmountMl: waterAmount,
            feedingIntervalDays: feedingFrequency,
            feedingType: feedingType,
            potSize: potSize.rawValue,
            environment: environment.rawValue,
            imageUrl: photoFilename
        )

        do {
            let result = try await UserPlantService.addPlant(request)
            newPlantId = result["id"]
            didAddPlant = true
        } catch let error as ApiError {
            errorMessage = error.errorDescription
            // Roll back the local photo if the backend rejected the plant.
            if let f = photoFilename { PhotoStorage.delete(f) }
        } catch {
            errorMessage = "Failed to add plant"
            if let f = photoFilename { PhotoStorage.delete(f) }
        }

        isAdding = false
    }

    // MARK: - Reset

    /// Reset all state for a new scan
    func reset() {
        scannedPlant = nil
        scannedBarcodeValue = nil
        nickname = ""
        location = ""
        notes = ""
        environment = .indoor
        potSize = .medium
        waterFrequency = 14
        waterAmount = 200
        feedingFrequency = 60
        feedingType = "General fertilizer"
        lightRequirement = "Flexible"
        enableNotification = true
        selectedImage = nil
        errorMessage = nil
        didAddPlant = false
        newPlantId = nil
    }

    // MARK: - Fill Defaults

    /// Fill form fields from the plant catalog data
    private func fillDefaults(from plant: Plant) {
        waterFrequency = plant.wateringIntervalDays ?? 14
        waterAmount = plant.wateringAmountMl ?? 200
        feedingFrequency = plant.feedingIntervalDays ?? 60
        feedingType = plant.feedingType ?? "General fertilizer"

        // Convert sunlight enum to display string
        if let sun = plant.sunlightRequirement {
            lightRequirement = sun
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
        }
    }

    // MARK: - Display Helpers

    var plantName: String {
        scannedPlant?.name ?? "Scan a barcode"
    }

    var scientificName: String {
        scannedPlant?.scientificName ?? ""
    }

    var plantImageUrl: String? {
        scannedPlant?.imageUrl
    }

    var plantNote: String? {
        scannedPlant?.note
    }
}
