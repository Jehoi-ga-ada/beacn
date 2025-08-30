//
//  ReportStore.swift
//  BEACN
//
//  Created by Jessica Lynn on 29/08/25.
//

import Foundation

@MainActor
class ReportStore: ObservableObject {
    @Published var reports: [Report] = []
    private let service = ReportService()
    
    func fetchAllReports() async {
        do {
            let fetched = try await service.getAllReports()
            self.reports = fetched
//            print("✅ Loaded \(fetched.count) reports")
//            for (index, report) in fetched.enumerated() {
//                print("Report \(index): lat=\(report.latitude ?? 0), lng=\(report.longitude ?? 0), category=\(report.categories.category)")
//            }
        } catch {
            print("❌ Failed to fetch reports:", error)
        }
    }
}
