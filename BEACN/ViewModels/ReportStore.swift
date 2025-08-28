//
//  ReportStore.swift
//  BEACN
//
//  Created by Jessica Lynn on 29/08/25.
//


import Foundation
import CoreLocation

class ReportStore: ObservableObject {
    @Published var reports: [Report] = [
        Report(
            category: "Flood Reported",
            emoji: "🌊",
            timestamp: Date(),
            reporter: "You",
            upvotes: 0,
            coordinate: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456)
        ),
        Report(
            category: "Traffic Jam",
            emoji: "🚗",
            timestamp: Date().addingTimeInterval(-300),
            reporter: "Jessica",
            upvotes: 3,
            coordinate: CLLocationCoordinate2D(latitude: -6.21, longitude: 106.84)
        )
    ]
}
