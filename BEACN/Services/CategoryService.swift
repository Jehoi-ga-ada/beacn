//
//  CategoryService.swift
//  BEACN
//
//  Created by Jehoiada Wong on 29/08/25.
//

import Foundation

// MARK: - Model
struct Category: Codable {
    let id: String?
    let category: String
    let broadCategories: BroadCategory?

    enum CodingKeys: String, CodingKey {
        case id, category
        case broadCategories = "broad_categories"
    }
}

// MARK: - Service
final class CategoryService: BaseService {
    init() {
        super.init(endpoint: "categories")
    }

    func getAllCategories() async throws -> [Category] {
        let request = try await makeRequest(method: "GET")
        return try await performRequest(request)
    }

    func getCategory(id: String) async throws -> Category {
        let request = try await makeRequest(path: id, method: "GET")
        return try await performRequest(request)
    }
}
