//
//  ReportStore.swift
//  BEACN
//
//  Created by Jessica Lynn on 29/08/25.
//


//import Foundation
//import CoreLocation
//
//@MainActor
//class ReportStore: ObservableObject {
//    private let reportService: ReportService
//    
//    @Published var reports: [Report] = []
//    @Published var error: Error? = nil
//    @Published var isLoading: Bool = false
//    
//    init(reportService: ReportService = ReportService()) {
//        self.reportService = reportService
//    }
//    
//    /// Loads reports asynchronously
//    func loadReports() async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        do {
//            let fetchedReports = try await reportService.getAllReports()
//            self.reports = fetchedReports
//            self.error = nil
//        } catch {
//            self.reports = []
//            self.error = error
//        }
//    }
//}

import Foundation

@MainActor
class ReportStore: ObservableObject {
    @Published var reports: [Report] = []
    private let service = ReportService()
    
    func fetchAllReports() async {
        do {
            let fetched = try await service.getAllReports()
            self.reports = fetched
            print("✅ Loaded \(fetched.count) reports")
            // In your ReportStore.fetchAllReports() method, add:
            for (index, report) in fetched.enumerated() {
                print("Report \(index): lat=\(report.latitude ?? 0), lng=\(report.longitude ?? 0), category=\(report.categories.category)")
            }
        } catch {
            print("❌ Failed to fetch reports:", error)
        }
    }
}
