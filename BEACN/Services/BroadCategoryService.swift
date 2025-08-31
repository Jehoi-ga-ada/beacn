//
//  BroadCategoryService.swift
//  BEACN
//
//  Created by Jehoiada Wong on 29/08/25.
//

import Foundation

// MARK: - Model
struct BroadCategory: Codable {
    let id: String?
    let broadCategory: String

    enum CodingKeys: String, CodingKey {
        case id
        case broadCategory = "broad_category"
    }
}

// MARK: - Service
final class BroadCategoryService: BaseService {
    init() {
        super.init(endpoint: "categories/broad")
    }

    func getAllBroadCategories() async throws -> [BroadCategory] {
        let request = try await makeRequest(method: "GET")
        return try await performRequest(request)
    }

    func getBroadCategory(id: String) async throws -> BroadCategory {
        let request = try await makeRequest(path: id, method: "GET")
        return try await performRequest(request)
    }
}
