//
//  SavedPlaceService.swift
//  BEACN
//
//  Created by Jehoiada Wong on 29/08/25.
//

import Foundation

// MARK: - Model
struct SavedPlace: Codable {
    let id: String
    let userId: String
    let name: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let emoji: String

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude
        case userId = "user_id"
        case createdAt = "created_at"
        case emoji
    }
}

struct CreateSavedPlaceRequest: Encodable {
    let type: String
    let name: String
    let latitude: Double
    let longitude: Double
    let emoji: String
}

// MARK: - Service
final class SavedPlaceService: BaseService {
    init() {
        super.init(endpoint: "savedplaces")
    }

    func getAllSavedPlaces() async throws -> [SavedPlace] {
        let request = try await makeRequest(method: "GET", useUserAuth: true)
        return try await performRequest(request)
    }

    func getSavedPlace(id: String) async throws -> SavedPlace {
        let request = try await makeRequest(path: id, method: "GET", useUserAuth: true)
        return try await performRequest(request)
    }

    func createSavedPlace(type: String, name: String, latitude: Double, longitude: Double, emoji: String) async throws -> SavedPlace {
        let body = try JSONEncoder().encode(CreateSavedPlaceRequest(
            type: type,
            name: name,
            latitude: latitude,
            longitude: longitude,
            emoji: emoji
        ))
        let request = try await makeRequest(method: "POST", body: body, useUserAuth: true)
        return try await performRequest(request)
    }

    func updateSavedPlace(id: String, name: String, latitude: Double, longitude: Double) async throws -> SavedPlace {
        let body = try JSONEncoder().encode([
            "name": name
        ])
        let request = try await makeRequest(path: id, method: "PUT", body: body)
        return try await performRequest(request)
    }

    func deleteSavedPlace(id: String) async throws -> Bool {
        struct DeleteResponse: Codable { let message: String }
        let request = try await makeRequest(path: id, method: "DELETE")
        let response: DeleteResponse = try await performRequest(request)
        return response.message.lowercased().contains("deleted")
    }
}
