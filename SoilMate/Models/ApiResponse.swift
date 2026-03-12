//
//  ApiResponse.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?

    /// Helper to check if request was successful
    var success: Bool { code == 200 }
}
