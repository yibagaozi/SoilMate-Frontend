//
//  PlantService.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

enum PlantService {

    private static let client = NetworkClient.shared

    /// Get a plant by its ID.
    static func getPlant(id: Int64) async throws -> Plant {
        try await client.get(APIEndpoints.plant(id: id))
    }

    /// Get a plant by scanning its barcode.
    /// Barcode format: PLT-XXXXX-XX
    static func getPlantByBarcode(_ barcodeValue: String) async throws -> Plant {
        try await client.get(APIEndpoints.plantByBarcode(code: barcodeValue))
    }
}
