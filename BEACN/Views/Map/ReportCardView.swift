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
    var onToggleUpvote: () async throws -> Int  // returns latest count

    @State private var isUpvoted: Bool = false
    @State private var upvoteCount: Int = 0
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(report.emoji) \(report.category)")
                    .font(.headline)
                Spacer()
                Text(report.timestamp, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Reported by \(report.reporter)")
                .font(.footnote)
                .foregroundColor(.secondary)

            Button {
                Task {
                    guard !isLoading else { return }
                    isLoading = true
                    do {
                        let newCount = try await onToggleUpvote()
                        withAnimation {
                            isUpvoted.toggle()
                            upvoteCount = newCount
                        }
                    } catch {
                        print("⚠️ Failed to toggle upvote: \(error)")
                    }
                    isLoading = false
                }
            } label: {
                HStack {
                    Image(systemName: isUpvoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                    Text(isUpvoted ? "Upvote (\(upvoteCount))" : "Upvote (\(upvoteCount))")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isUpvoted ? Color.green : Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .disabled(isLoading)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 4)
        .padding(.horizontal)
        .onAppear {
            upvoteCount = report.upvotes
        }
    }
}



//#Preview {
//    ReportCardView(
//        report: ReportView(
//            category: "Road Problems",
//            emoji: "🚧",
//            timestamp: Date(),
//            reporter: "Jessica Lynn",
//            upvotes: 12,
//            coordinate: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456)
//        ),
//        onUpvote: { print("Upvoted!") }
//    )
//}

