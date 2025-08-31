//
//  BaseService.swift
//  BEACN
//
//  Created by Jehoiada Wong on 29/08/25.
//

import Foundation

class BaseService {
    let baseURL: URL
    let session: URLSession

    init(endpoint: String, session: URLSession = .shared) {
        self.baseURL = Config.supabaseURL.appendingPathComponent("functions/v1/\(endpoint)")
        self.session = session
    }

    func makeRequest(path: String = "",
                     method: String,
                     body: Data? = nil,
                     query: [URLQueryItem]? = nil,
                     useUserAuth: Bool = false) async throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path),
                                             resolvingAgainstBaseURL: false) else {
            throw ServiceError.invalidURL
        }
        if let query = query {
            components.queryItems = query
        }
        guard let url = components.url else { throw ServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if useUserAuth {
            let sessionKey = try await supabase.auth.session.accessToken
            request.setValue("Bearer \(sessionKey)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(Config.supabaseServiceRoleKey)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        return request
    }

    func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.serverError
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func performRawRequest(_ request: URLRequest) async throws -> Any {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.serverError
        }
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}

// MARK: - Shared Errors
enum ServiceError: LocalizedError {
    case invalidURL
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL for service endpoint."
        case .serverError: return "Server returned an error response."
        }
    }
}
