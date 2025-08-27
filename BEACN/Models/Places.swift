//
//  Places.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import Foundation
import CoreLocation

struct Place: Identifiable, Hashable {
    let id: Int
    let uuid: String
    let latitude: Double
    let longitude: Double
    let name: String
    let emoji: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
