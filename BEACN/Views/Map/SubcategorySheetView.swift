//
//  SubcategorySheetView.swift
//  BEACN
//
//  Created by Jessica Lynn on 28/08/25.
//
import SwiftUI

struct SubcategorySheetView: View {
    let type: ReportType
    let onBack: () -> Void
    let onSelect: (ReportSubcategory) -> Void
    
    private var columns: [GridItem] {
        type.subcategories.count <= 4
            ? [GridItem(.flexible()), GridItem(.flexible())]
            : [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(8)
                }
                Spacer()
                Text("\(type.rawValue)")
                    .font(.headline)
                Spacer()
                // dummy spacer to balance layout
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(type.subcategories) { sub in
                    VStack(spacing: 8) {
                        Button(action: { onSelect(sub) }) {
                            Text(sub.emoji)
                                .font(.system(size: 32))
                                .frame(width: 80, height: 80)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        Text(sub.name)
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
