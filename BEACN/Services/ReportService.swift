//
//  ReportService.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//
import SwiftUI

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
