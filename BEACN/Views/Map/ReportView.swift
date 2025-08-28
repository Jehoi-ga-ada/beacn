//
//  ReportView.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI

struct ReportSheetView: View {
    let onSelect: (ReportType) -> Void
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("What's happening near you?")
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(ReportType.allCases) { type in
                    VStack(spacing: 8) {
                        Button(action: { onSelect(type) }) {
                            Text(type.emoji)
                                .font(.system(size: 36))
                                .frame(width: 80, height: 80)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        Text(type.rawValue)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 100)
                    }
                }
            }
            .padding(.horizontal, 50)
            
            Spacer()
        }
        .padding(.top, 20)
    }
}
