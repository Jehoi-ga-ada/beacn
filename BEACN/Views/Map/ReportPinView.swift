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
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 50, height: 50)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 3)
            
            // picker stick
            Rectangle()
                .fill(Color.gray)
                .frame(width: 3, height: 13)
        }
    }
}
