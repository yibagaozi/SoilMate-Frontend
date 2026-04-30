//
//  NetworkClient.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/2/27.
//

import Foundation

final class NetworkClient {

    static let shared = NetworkClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)

        // Backend uses camelCase in JSON, so default decoding works.
        // If backend ever switches to snake_case, add:
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Public Methods

    /// GET request. Returns decoded data from ApiResponse wrapper.
    func get<T: Decodable>(
        _ path: String,
        query: [String: String]? = nil
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "GET", query: query)
        return try await perform(request)
    }

    /// POST request with a JSON body.
    func post<T: Decodable, B: Encodable>(
        _ path: String,
        body: B
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "POST", body: body)
        return try await perform(request)
    }

    /// POST request with no body (e.g. complete task with defaults).
    func post<T: Decodable>(
        _ path: String
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "POST")
        return try await perform(request)
    }

    /// PATCH request with a JSON body.
    func patch<T: Decodable, B: Encodable>(
        _ path: String,
        body: B
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "PATCH", body: body)
        return try await perform(request)
    }

    /// PATCH where the backend returns no data (data: null), e.g. update endpoints.
    /// Status-code check only; no JSON decoding of the body.
    func patchNoContent<B: Encodable>(_ path: String, body: B) async throws {
        let request = try buildRequest(path: path, method: "PATCH", body: body)
        try await performNoContent(request)
    }

    /// DELETE request. Returns nothing.
    func delete(_ path: String) async throws {
        let request = try buildRequest(path: path, method: "DELETE")
        let (_, response) = try await session.data(for: request)
        try checkHTTPStatus(response)
    }

    /// POST without decoding response (for endpoints that return 204 or empty).
    func postNoContent<B: Encodable>(
        _ path: String,
        body: B
    ) async throws {
        let request = try buildRequest(path: path, method: "POST", body: body)
        try await performNoContent(request)
    }

    // MARK: - Auth Requests (no token needed)

    /// Special method for auth endpoints (login, register, refresh).
    /// These do NOT attach Bearer token and do NOT retry on 401.
    func authRequest<T: Decodable, B: Encodable>(
        _ path: String,
        body: B
    ) async throws -> T {
        let request = try buildRequest(path: path, method: "POST", body: body, skipAuth: true)
        return try await performDirect(request)
    }

    // MARK: - Build Request

    private func buildRequest(
        path: String,
        method: String,
        query: [String: String]? = nil,
        body: (any Encodable)? = nil,
        skipAuth: Bool = false
    ) throws -> URLRequest {

        // Build URL with query params
        guard var components = URLComponents(string: APIEndpoints.baseURL + path) else {
            throw ApiError.invalidURL
        }

        if let query {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token (unless this is a login/register call)
        if !skipAuth, let token = KeychainHelper.read(key: KeychainHelper.accessTokenKey) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode body
        if let body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    // MARK: - Perform Request (with 401 retry)

    /// Sends request. If 401, refreshes token and retries once.
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            return try await performDirect(request)
        } catch ApiError.unauthorized {
            // Try to refresh the token
            try await refreshToken()

            // Rebuild request with new token
            var retryRequest = request
            if let token = KeychainHelper.read(key: KeychainHelper.accessTokenKey) {
                retryRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            return try await performDirect(retryRequest)
        }
    }

    /// Same retry-on-401 behavior as `perform`, but does not decode the body.
    /// Used by patchNoContent / postNoContent.
    private func performNoContent(_ request: URLRequest) async throws {
        do {
            let (_, response) = try await session.data(for: request)
            try checkHTTPStatus(response)
        } catch ApiError.unauthorized {
            try await refreshToken()

            var retryRequest = request
            if let token = KeychainHelper.read(key: KeychainHelper.accessTokenKey) {
                retryRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            let (_, response) = try await session.data(for: retryRequest)
            try checkHTTPStatus(response)
        }
    }

    /// Sends request directly, no retry.
    private func performDirect<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw ApiError.noConnection
            case .timedOut:
                throw ApiError.timeout
            default:
                throw ApiError.unknown(error.localizedDescription)
            }
        }

        try checkHTTPStatus(response, data: data)

        // Decode the ApiResponse wrapper
        let apiResponse: ApiResponse<T>
        do {
            apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)
        } catch {
            throw ApiError.decodingFailed
        }

        // Return the inner data
        guard let result = apiResponse.data else {
            throw ApiError.unknown(apiResponse.message ?? "No data in response")
        }

        return result
    }

    // MARK: - Token Refresh

    private func refreshToken() async throws {
        guard let refreshToken = KeychainHelper.read(key: KeychainHelper.refreshTokenKey) else {
            throw ApiError.tokenRefreshFailed
        }

        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let request = try buildRequest(
            path: APIEndpoints.refresh,
            method: "POST",
            body: body,
            skipAuth: true
        )

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ApiError.tokenRefreshFailed
        }

        // If refresh also fails with 401, user must log in again
        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            clearTokens()
            throw ApiError.tokenRefreshFailed
        }

        let apiResponse = try decoder.decode(ApiResponse<TokenResponse>.self, from: data)
        guard let tokens = apiResponse.data else {
            throw ApiError.tokenRefreshFailed
        }

        // Save new tokens
        KeychainHelper.save(key: KeychainHelper.accessTokenKey, value: tokens.accessToken)
        KeychainHelper.save(key: KeychainHelper.refreshTokenKey, value: tokens.refreshToken)
    }

    private func clearTokens() {
        KeychainHelper.delete(key: KeychainHelper.accessTokenKey)
        KeychainHelper.delete(key: KeychainHelper.refreshTokenKey)
    }

    // MARK: - HTTP Status Check

    private func checkHTTPStatus(_ response: URLResponse, data: Data? = nil) throws {
        guard let http = response as? HTTPURLResponse else { return }

        switch http.statusCode {
        case 200...299:
            return  // all good
        case 401:
            throw ApiError.unauthorized
        case 403:
            throw ApiError.forbidden
        case 404:
            throw ApiError.notFound
        case 409:
            let msg = extractMessage(from: data) ?? "Conflict"
            throw ApiError.conflict(msg)
        case 400, 422:
            let msg = extractMessage(from: data) ?? "Invalid request"
            throw ApiError.validationFailed(msg)
        default:
            throw ApiError.serverError
        }
    }

    /// Try to read the "message" field from an error response
    private func extractMessage(from data: Data?) -> String? {
        guard let data else { return nil }
        let response = try? decoder.decode(ApiResponse<EmptyData>.self, from: data)
        return response?.message
    }
}

/// Used when we only care about the message, not the data
private struct EmptyData: Decodable {}
