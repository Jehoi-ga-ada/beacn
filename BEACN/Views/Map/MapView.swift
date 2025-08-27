//
//  MapView.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel: MapVM
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var isSearching: Bool = false
    @FocusState private var searchFieldFocused: Bool


    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    userTrackingMode: $trackingMode,
                    annotationItems: viewModel.savedPlaces) { place in
                    
                    MapAnnotation(coordinate: place.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                            Circle()
                                .fill(beaconGradient)
                                .frame(width: 36, height: 36)
                            Text(place.emoji)
                                .font(.title2)
                        }
                        .shadow(radius: 4)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search places…", text: $viewModel.searchQuery, onEditingChanged: { editing in
                            if editing {
                                withAnimation {
                                    isSearching = true
                                }
                            }
                        }, onCommit: {
                            viewModel.searchPlaces()
                            trackingMode = .none
                        })
                        .focused($searchFieldFocused)
                    }
                    .padding(15)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(30)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    if !viewModel.searchResults.isEmpty {
                        List(viewModel.searchResults, id: \.self) { item in
                            Button(action: {
                                if let coord = item.placemark.location?.coordinate {
                                    viewModel.region = MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    )
                                }
                                viewModel.searchResults = [] // close list
                            }) {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unknown")
                                        .font(.headline)
                                    Text(item.placemark.title ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        ZStack {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    viewModel.toggleOrbit()
                                }
                            }) {
                                Image(systemName: "bookmark.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(18)
                                    .foregroundStyle(beaconGradient)
                                    .frame(width: 70, height: 70)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            
                            if viewModel.showOrbit {
                                OrbitView(
                                    places: viewModel.savedPlaces,
                                    onAdd: { print("Add tapped") },
                                    onSelect: { place in
                                        withAnimation {
                                            viewModel.region = MKCoordinateRegion(
                                                center: place.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                            )
                                            isSearching = false
                                            searchFieldFocused = false
                                        }
                                    },
                                    radius: 90
                                )
                                .offset(x: 0, y: -5)
                            }
                        }
                        .frame(width: 100, height: 100)
                        
                        Spacer()
                        
                        Button(action: { print("Megaphone tapped") }) {
                            Image(systemName: "megaphone.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(18)
                                .foregroundStyle(Color.white)
                                .frame(width: 70, height: 70)
                                .background(beaconGradient)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                if isSearching {
                    SearchOverlayView(
                        isSearching: $isSearching,
                        searchFieldFocused: $searchFieldFocused,
                        recentSearches: viewModel.recentSearches,
                        savedPlaces: viewModel.savedPlaces,
                        onRecentSelected: { recent in
                            dismissSearch()
                        },
                        onSavedPlaceSelected: { place in
                            withAnimation {
                                viewModel.focusOn(place)
                            }
                            dismissSearch()
                        }
                    )
                    .transition(.move(edge: .top))
                    .zIndex(1)
                }




            }
        }
    }
    private func dismissSearch() {
        withAnimation {
            isSearching = false
            searchFieldFocused = false
        }
    }
}



struct OrbitView: View {
    let places: [Place]
    let onAdd: () -> Void
    let onSelect: (Place) -> Void
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
    @Binding var isSearching: Bool
    @FocusState<Bool>.Binding var searchFieldFocused: Bool
    var recentSearches: [RecentSearch]
    var savedPlaces: [Place]
    var onRecentSelected: (RecentSearch) -> Void
    var onSavedPlaceSelected: (Place) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Recents Section
                if !recentSearches.isEmpty {
                    Text("Recents")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(recentSearches) { recent in
                            ItemRow(title: recent.name, icon: "magnifyingglass")
                                .onTapGesture {
                                    onRecentSelected(recent)
                                    dismissOverlay()
                                }
                        }
                    }
                }
                
                // Saved Places Section
                if !savedPlaces.isEmpty {
                    Text("Saved Places")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(savedPlaces) { place in
                            ItemRow(title: place.name, icon: nil, emoji: place.emoji)
                                .onTapGesture {
                                    onSavedPlaceSelected(place)
                                    dismissOverlay()
                                }
                        }
                    }
                }
            }
            .padding(.top, 20)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 200)
            
            Spacer()
        }
    }
    private func dismissOverlay() {
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
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct RecentSearch: Identifiable {
    let id = UUID()
    let name: String
    // Add other relevant data like coordinates if needed
}

