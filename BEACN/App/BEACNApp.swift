//
//  BEACNApp.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI
import SwiftData

@main
struct BEACNApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    init() {
        Task {
            let authService = AuthService()
            do {
                _ = try await authService.signIn(email: "sayajehoiada@gmail.com", password: "Jehoiada1509!")
            } catch {
                print("Login failed")
            }
        }
    }
    
    @StateObject private var appCoordinator = AppCoordinator()
    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
        }
    }
}

// MARK: - Testing purposes only, remove on pull request to main.
//@main
//struct BEACNApp: App {
//    init() {
//        Task {
//            let authService = AuthService()
//            do {
//                _ = try await authService.signIn(email: "sayajehoiada@gmail.com", password: "Jehoiada1509!")
//            } catch {
//                print("Login failed")
//            }
//            
//            // MARK: - Done
//            let categoryService = CategoryService()
//            do {
//                let categories = try await categoryService.getAllCategories()
//                let categoryName = "Flood"
//                guard let category = categories.first(where: { $0.category.lowercased() == categoryName.lowercased() }),
//                      let categoryId = category.id else {
//                    throw NSError(domain: "ReportService",
//                                  code: 404,
//                                  userInfo: [NSLocalizedDescriptionKey: "Category '\(categoryName)' not found"])
//                }
//                print("Found:", categoryId)
//                print("✅ Categories:", categories)
//            } catch {
//                print("❌ Error:", error)
//            }
//            
//            // MARK: - Done
//            let broadCategoryService = BroadCategoryService()
//            do {
//                let broadCategories = try await broadCategoryService.getAllBroadCategories()
//                print("✅ Broad Categories:", broadCategories)
//            } catch {
//                print("❌ Error:", error)
//            }
//            
//            // MARK: - Done
//            let attachmentService = AttachmentService()
//            do {
//                let attachments = try await attachmentService.getAllAttachments()
//                print("✅ Attachments:", attachments)
//            } catch {
//                print("❌ Error:", error)
//            }
//            
//            // MARK: - Done
//            let reportService = ReportService()
//            do {
//                let reports = try await reportService.createReport(categoryName: "Flood", latitude: 999, longitude: 999)
//                print("✅ Reports:", reports)
//            } catch {
//                print("❌ Error:", error)
//            }
//            
//            // MARK: - Done
//            let upvoteService = UpvoteService()
//            do {
//                let upvotes = try await upvoteService.getUpvotes(reportId: "ead318ef-e8fb-4e4f-9dee-adc31667c11a")
//                print("✅ Upvotes:", upvotes)
//            } catch {
//                print("❌ Error:", error)
//            }
//            
//            let savedPlaceService = SavedPlaceService()
//            do {
//                let savedPlaces = try await savedPlaceService.getAllSavedPlaces()
//                print("✅ Saved Places:", savedPlaces)
//            } catch {
//                print("❌ Error:", error)
//            }
//        }
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView() // can be empty
//        }
//    }
//}
