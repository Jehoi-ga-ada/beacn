//
//  ReportService.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import Foundation

// MARK: - Protocol
protocol ReportServiceProtocol {
    func createReport(categoryId: String, latitude: Double, longitude: Double) async throws -> Report
    func getAllReports() async throws -> [Report]
    func getReports(lat: Double, lng: Double, radius: Double) async throws -> [Report]
    func updateReport(id: String, latitude: Double, longitude: Double) async throws -> Report
    func deleteReport(id: String) async throws -> Bool
}

// MARK: - Models
struct ReportUpvoteCount: Codable {
    let count: Int
    enum CodingKeys: String, CodingKey {
        case count
    }
}

struct Report: Codable {
    let id: String
    let userId: String
    let categoryId: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String?
    let categories: Category
    let attachments: [Attachment]?
    let reportUpvoteCount: [ReportUpvoteCount]?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case latitude, longitude
        case createdAt = "created_at"
        case categories, attachments
        case reportUpvoteCount = "report_upvotes"
    }
}

struct CreateReportRequest: Encodable {
    let category_id: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Service
final class ReportService: BaseService, ReportServiceProtocol {
    init() {
        super.init(endpoint: "reports")
    }

    func createReport(categoryId: String, latitude: Double, longitude: Double) async throws -> Report {
        let body = try JSONEncoder().encode(CreateReportRequest(
            category_id: categoryId,
            latitude: latitude,
            longitude: longitude
        ))
        let request = try await makeRequest(method: "POST", body: body)
        return try await performRequest(request)
    }

    func getAllReports() async throws -> [Report] {
        let request = try await makeRequest(method: "GET")
        return try await performRequest(request)
    }

    func getReports(lat: Double, lng: Double, radius: Double) async throws -> [Report] {
        let query = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lng", value: "\(lng)"),
            URLQueryItem(name: "radius", value: "\(radius)")
        ]
        let request = try await makeRequest(method: "GET", query: query)
        return try await performRequest(request)
    }

    func updateReport(id: String, latitude: Double, longitude: Double) async throws -> Report {
        let body = try JSONEncoder().encode([
            "latitude": latitude,
            "longitude": longitude
        ])
        let request = try await makeRequest(path: id, method: "PUT", body: body)
        return try await performRequest(request)
    }

    func deleteReport(id: String) async throws -> Bool {
        struct DeleteResponse: Codable { let message: String }
        let request = try await makeRequest(path: id, method: "DELETE")
        let response: DeleteResponse = try await performRequest(request)
        return response.message.lowercased().contains("deleted")
    }
}
