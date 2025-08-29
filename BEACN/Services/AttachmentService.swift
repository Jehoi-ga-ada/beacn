//
//  AttachmentServiceProtocol.swift
//  BEACN
//
//  Created by Jehoiada Wong on 29/08/25.
//

import Foundation

// MARK: - Protocol
protocol AttachmentServiceProtocol {
    func getAllAttachments() async throws -> [Attachment]
    func getAttachments(byReportId reportId: String) async throws -> [Attachment]
    func getAttachment(id: String) async throws -> Attachment
    func createAttachment(reportId: String, imageUrl: String) async throws -> Attachment
}

struct Attachment: Codable {
    let id: String
    let reportId: String
    let imageUrl: String
    let createdAt: String
    let reports: Report?

    enum CodingKeys: String, CodingKey {
        case id
        case reportId = "report_id"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case reports
    }
}

// MARK: - Service
final class AttachmentService: BaseService, AttachmentServiceProtocol {
    init() {
        super.init(endpoint: "attachments")
    }

    func getAllAttachments() async throws -> [Attachment] {
        let request = try await makeRequest(method: "GET")
        return try await performRequest(request)
    }

    func getAttachments(byReportId reportId: String) async throws -> [Attachment] {
        let query = [URLQueryItem(name: "report_id", value: reportId)]
        let request = try await makeRequest(method: "GET", query: query)
        return try await performRequest(request)
    }

    func getAttachment(id: String) async throws -> Attachment {
        let request = try await makeRequest(path: id, method: "GET")
        return try await performRequest(request)
    }

    func createAttachment(reportId: String, imageUrl: String) async throws -> Attachment {
        let body = try JSONEncoder().encode([
            "report_id": reportId,
            "image_url": imageUrl
        ])
        let request = try await makeRequest(method: "POST", body: body, useUserAuth: true)
        return try await performRequest(request)
    }
    
    func updateAttachment(attachmentId: String, imageUrl: String) async throws -> Attachment {
        let body = try JSONEncoder().encode([
            "image_url": imageUrl
        ])
        let request = try await makeRequest(path: attachmentId, method: "PUT", body: body, useUserAuth: true)
        return try await performRequest(request)
    }
    
    func deleteAttachment(attachmentId: String, imageUrl: String) async throws -> Attachment {
        let request = try await makeRequest(path: attachmentId, method: "DELETE", useUserAuth: true)
        return try await performRequest(request)
    }
}
