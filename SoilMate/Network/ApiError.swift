//
//  ApiError.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

/// All possible errors from network calls
enum ApiError: LocalizedError {

    // -- Network errors --
    case noConnection
    case timeout
    case invalidURL

    // -- Server errors --
    case unauthorized          // 401 - token expired or invalid
    case forbidden             // 403 - no permission
    case notFound              // 404 - resource not found
    case conflict(String)      // 409 - e.g. email already exists
    case validationFailed(String) // 400 - bad request
    case serverError           // 500+

    // -- Client errors --
    case decodingFailed
    case tokenRefreshFailed    // refresh token also expired
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .invalidURL:
            return "Invalid URL"
        case .unauthorized:
            return "Please log in again"
        case .forbidden:
            return "You don't have permission"
        case .notFound:
            return "Not found"
        case .conflict(let msg):
            return msg
        case .validationFailed(let msg):
            return msg
        case .serverError:
            return "Server error, please try later"
        case .decodingFailed:
            return "Failed to read server response"
        case .tokenRefreshFailed:
            return "Session expired, please log in again"
        case .unknown(let msg):
            return msg
        }
    }
}
