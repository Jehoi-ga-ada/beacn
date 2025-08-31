//
//  ReportPinView.swift
//  BEACN
//
//  Created by Jessica Lynn on 29/08/25.
//
import SwiftUI

struct ReportPinView: View {
    let emoji: String
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 54, height: 54)
                
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [Color(hex: "FF6B6D"), Color(hex: "B10003")]),
                        center: .topTrailing,
                        startRadius: 5,
                        endRadius: 100
                    ))
                    .frame(width: 50, height: 50)
                
                Text(emoji)
                    .font(.system(size: 28))
            }
            .shadow(radius: 3)
            
            // picker stick
            Rectangle()
                .fill(Color.gray)
                .frame(width: 3, height: 13)
        }
    }
}
