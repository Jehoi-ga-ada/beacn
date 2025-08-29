//
//  UpvoteService.swift
//  BEACN
//
//  Created by Jehoiada Wong on 29/08/25.
//

import Foundation

// MARK: - Models
struct Upvote: Codable {
    let id: String
    let reportId: String
    let userId: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case reportId = "report_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct UpvoteResponse: Codable {
    let message: String
    let count: Int?
}

// MARK: - Service
final class UpvoteService: BaseService {
    init() {
        super.init(endpoint: "upvotes")
    }

    func getUpvotes(reportId: String) async throws -> [Upvote] {
        let query = [URLQueryItem(name: "report_id", value: reportId)]
        let request = try await makeRequest(method: "GET", query: query, useUserAuth: true)
        return try await performRequest(request)
    }

    func toggleUpvote(reportId: String) async throws -> UpvoteResponse {
        let body = try JSONEncoder().encode(["report_id": reportId])
        let request = try await makeRequest(method: "POST", body: body)
        return try await performRequest(request)
    }

    func removeUpvote(reportId: String) async throws -> Bool {
        let request = try await makeRequest(path: reportId, method: "DELETE")
        let response: UpvoteResponse = try await performRequest(request)
        return response.message.lowercased().contains("deleted")
    }
}
