//
//  MapView+Helper.swift
//  BEACN
//
//  Created by Jessica Lynn on 31/08/25.
//

import SwiftUI
import MapKit

struct OrbitView: View {
    let places: [Place]
    let onAdd: () -> Void
    let onSelect: (Place) -> Void
    let onLongPress: (Place) -> Void
    let radius: CGFloat
    
    var body: some View {
        ZStack {
            let total = places.count + 1
            let startAngle = -10.0 * (.pi / 180)
            let endAngle = 110.0 * (.pi / 180)
            
            ForEach(0..<total, id: \.self) { index in
                let angle = startAngle + (Double(index) / Double(max(total - 1, 1))) * (endAngle - startAngle)
                
                if index < places.count {
                    Button(action: {
                        onSelect(places[index])
                    }) {
                        Text(places[index].emoji)
                            .font(.largeTitle)
                            .padding(10)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 4)
                    }
                    .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 10) {
                        print("long press") //tacky gesture
                        onLongPress(places[index])
                    }
                    .offset(x: cos(angle) * radius,
                            y: -sin(angle) * radius)
                } else {
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .padding(12)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 3)
                    }
                    .offset(x: cos(angle) * radius,
                            y: -sin(angle) * radius)
                }
            }
        }
    }
}


struct SearchOverlayView: View {
    @ObservedObject var viewModel: MapVM
    @Binding var isSearching: Bool
    @FocusState<Bool>.Binding var searchFieldFocused: Bool
    @Binding var query: String
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { dismissOverlay() }
            
            VStack(alignment: .leading, spacing: 16) {
                BeaconSearchBar(
                    text: $query,
                    isSearching: $isSearching,
                    searchFieldFocused: $searchFieldFocused,
                    showsCancel: true,
                    onCancel: { dismissOverlay() },
                    onSubmit: {
                        viewModel.searchPlaces()
                        dismissOverlay() // Add this line
                    }
                )
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if !viewModel.recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recents")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(viewModel.recentSearches) { recent in
                                    ItemRow(title: recent.name, icon: "magnifyingglass")
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            viewModel.searchQuery = recent.name
                                            viewModel.searchPlaces()
                                            viewModel.searchQuery = "" // Clear after search
                                            dismissOverlay()
                                        }
                                }
                            }
                        }
                        
                        if !viewModel.savedPlaces.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Saved Places")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(viewModel.savedPlaces) { place in
                                    ItemRow(title: place.name, emoji: place.emoji)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            viewModel.focusOn(place)
                                            viewModel.searchQuery = "" // Clear query
                                            dismissOverlay()
                                        }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .transition(.opacity)
    }
    
    private func dismissOverlay() {
        viewModel.searchQuery = "" // Clear query when dismissing
        withAnimation {
            isSearching = false
            searchFieldFocused = false
        }
    }
}

struct ItemRow: View {
    var title: String
    var icon: String?
    var emoji: String?

    var body: some View {
        HStack(spacing: 16) {
            if let emoji = emoji {
                Text(emoji)
                    .font(.title2)
            } else if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(title)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}


struct RecentSearch: Identifiable {
    let id = UUID()
    let name: String
    
}

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    
    enum AnnotationType {
        case place(Place)
        case report(Report)
    }
}
