//
//  Color.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

let beaconGradient = RadialGradient(
    gradient: Gradient(colors: [Color(hex: "5091D3"), Color(hex: "005DAD")]),
    center: .topTrailing,
    startRadius: 5,
    endRadius: 100
)
let cameraGradient = RadialGradient(
    gradient: Gradient(colors: [Color(hex: "FFBB73"), Color(hex: "FF8400")]),
    center: .topTrailing,
    startRadius: 5,
    endRadius: 100
)
