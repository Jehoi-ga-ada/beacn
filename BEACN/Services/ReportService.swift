//
//  ReportService.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//
import SwiftUI
import MapKit

enum ReportType: String, CaseIterable, Identifiable {
    case road = "Road Problems"
    case weather = "Weather & Environment"
    case emergency = "Emergency & Danger"
    case outage = "Outages"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .road: return "🛣️"
        case .weather: return "🌦️"
        case .emergency: return "🚨"
        case .outage: return "⚡️"
        }
    }

    var subcategories: [ReportSubcategory] {
        switch self {
        case .road:
            return [
                .init(name: "Road closed", emoji: "⛔️"),
                .init(name: "Traffic jam", emoji: "🚗"),
                .init(name: "Accident", emoji: "💥"),
                .init(name: "Protest", emoji: "📢"),
                .init(name: "Construction", emoji: "🚧"),
                .init(name: "Broken traffic light", emoji: "🚦")
            ]
        case .weather:
            return [
                .init(name: "Flood", emoji: "🌊"),
                .init(name: "Heavy rain", emoji: "🌧️"),
                .init(name: "Heavy storm", emoji: "⛈️"),
                .init(name: "Fallen tree", emoji: "🌳"),
                .init(name: "Earthquake", emoji: "🌍"),
                .init(name: "Landslide", emoji: "🏔️")
            ]
        case .emergency:
            return [
                .init(name: "Crime nearby", emoji: "👮‍♂️"),
                .init(name: "Fire in nearby building", emoji: "🔥"),
                .init(name: "Building collapse", emoji: "🏚️")
            ]
        case .outage:
            return [
                .init(name: "Power outage", emoji: "💡"),
                .init(name: "No water", emoji: "🚱"),
                .init(name: "Mobile or internet down", emoji: "📵"),
                .init(name: "Gas leak or explosion", emoji: "💨")
            ]
        }
    }
}

struct ReportSubcategory: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
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
final class ReportService: BaseService {
    let categoryService = CategoryService()
    init() {
        super.init(endpoint: "reports")
    }

    func createReport(categoryName: String, latitude: Double, longitude: Double) async throws -> Report {
        let categories = try await categoryService.getAllCategories()
        guard let category = categories.first(where: { $0.category.lowercased() == categoryName.lowercased() }),
              let categoryId = category.id else {
            throw NSError(domain: "ReportService",
                          code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Category '\(categoryName)' not found"])
        }
        
        let body = try JSONEncoder().encode(CreateReportRequest(
            category_id: categoryId,
            latitude: latitude,
            longitude: longitude
        ))
        let request = try await makeRequest(method: "POST", body: body, useUserAuth: true)
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

extension Report {
    var emoji: String {
        let subcategoryName = categories.category // this is the "Flood", "Traffic jam", etc.
        
        for type in ReportType.allCases {
            if let match = type.subcategories.first(where: { $0.name == subcategoryName }) {
                return match.emoji
            }
        }
        return "📍" // fallback if no match found
    }
}


extension Report {
    func toReportView() -> ReportView {
        let timestamp: Date = {
            guard let createdAtString = self.createdAt else { return Date() }
            
            // Try ISO8601 with fractional seconds first
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: createdAtString) {
                return date
            }
            
            // Fallback to standard ISO8601
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: createdAtString) {
                return date
            }
            
            print("⚠️ Failed to parse date string: '\(createdAtString)'")
            return Date()
        }()
        
        return ReportView(
            category: self.categories.category,
            emoji: self.emoji,
            timestamp: timestamp,
            reporter: "User",
            upvotes: self.reportUpvoteCount?.first?.count ?? 0,
            coordinate: CLLocationCoordinate2D(
                latitude: self.latitude ?? 0,
                longitude: self.longitude ?? 0
            )
        )
    }
}
