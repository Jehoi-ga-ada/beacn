//
//  ReportCardView.swift
//  BEACN
//
//  Created by Jessica Lynn on 29/08/25.
//


import SwiftUI
import MapKit

struct ReportCardView: View {
    let report: ReportView
    var onUpvote: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(report.emoji) \(report.category)")
                    .font(.headline)
                Spacer()
                Text(report.timestamp, style: .date) //change styling here, .time/date
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                print("Add photo tapped")
            } label: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Add Photo")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            Text("Reported by \(report.reporter)")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button(action: onUpvote) {
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("Upvote (\(report.upvotes))")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}

#Preview {
    ReportCardView(
        report: ReportView(
            category: "Road Problems",
            emoji: "🚧",
            timestamp: Date(),
            reporter: "Jessica Lynn",
            upvotes: 12,
            coordinate: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456)
        ),
        onUpvote: { print("Upvoted!") }
    )
}

