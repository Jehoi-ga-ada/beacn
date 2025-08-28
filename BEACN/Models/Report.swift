//
//  Report.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import Foundation
import CoreLocation

struct Report: Identifiable {
    let id = UUID()
    let category: String
    let emoji: String
    let timestamp: Date
    let reporter: String
    var upvotes: Int
    var coordinate: CLLocationCoordinate2D
    var attachments: [String] = [] // placeholder image URLs
}
