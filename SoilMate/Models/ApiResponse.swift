//
//  ApiResponse.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
}
