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
    @StateObject var reportStore = ReportStore()
    @State private var selectedReport: Report?



    
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
                    if !isSearching {
                        BeaconSearchBar(
                            text: $viewModel.searchQuery,
                            isSearching: $isSearching,
                            searchFieldFocused: $searchFieldFocused,
                            showsCancel: false,
                            onSubmit: {
                                viewModel.searchPlaces()
                                dismissSearch()
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 17)
                    }
                    
                    if !viewModel.searchResults.isEmpty {
                        List(viewModel.searchResults, id: \.self) { item in
                            Button(action: {
                                if let coord = item.placemark.location?.coordinate {
                                    viewModel.region = MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                }
                                viewModel.searchResults = []
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
                        
                        Button(action: { viewModel.showReportSheet = true }) {
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
                        .sheet(isPresented: $viewModel.showReportSheet) {
                            if let selectedType = viewModel.selectedReportType {
                                // Show subcategories if a category is selected
                                SubcategorySheetView(
                                    type: selectedType,
                                    onBack: { viewModel.selectedReportType = nil },
                                    onSelect: { sub in
                                        viewModel.selectedReportType = nil
                                        viewModel.showReportSheet = false
                                        viewModel.selectedSubcategory = sub
                                        
                                        // Show location picker
                                        if let current = viewModel.region.center as CLLocationCoordinate2D? {
                                            viewModel.showLocationPicker = true
                                        }
                                    }
                                )

                                .presentationDetents([.medium])
                            } else {
                                // Show main categories first
                                ReportSheetView { type in
                                    viewModel.selectedReportType = type
                                }
                                .presentationDetents([.medium])
                            }
                        }

                    }
                    .padding(.horizontal, 20)
                }
                if isSearching {
                    SearchOverlayView(
                        isSearching: $isSearching,
                        searchFieldFocused: $searchFieldFocused,
                        query: $viewModel.searchQuery,
                        recentSearches: viewModel.recentSearches,
                        savedPlaces: viewModel.savedPlaces,
                        onRecentSelected: { recent in
                            viewModel.searchQuery = recent.name
                            viewModel.searchPlaces()
                            dismissSearch()
                        },
                        onSavedPlaceSelected: { place in
                            withAnimation {
                                viewModel.focusOn(place)
                            }
                            dismissSearch()
                        },
                        onSubmit: { // 👈 wire in parent logic
                            viewModel.searchPlaces()
                            dismissSearch()
                        }
                    )
                    .transition(.move(edge: .top))
                    .zIndex(1)
                }




            }
        }
        .fullScreenCover(isPresented: $viewModel.showLocationPicker) {
            ReportLocationPickerView(
                userLocation: viewModel.region.center,
                emoji: viewModel.selectedSubcategory?.emoji ?? "📍"
            ) { coord in
                print("User placed report at: \(coord.latitude), \(coord.longitude)")
                // TODO: Save report with coord + selectedSubcategory
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
    @Binding var query: String
    
    var recentSearches: [RecentSearch]
    var savedPlaces: [Place]
    var onRecentSelected: (RecentSearch) -> Void
    var onSavedPlaceSelected: (Place) -> Void
    var onSubmit: (() -> Void)? = nil
    
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
                    onSubmit: {
                        onSubmit?() // 👈 call parent
                    }
                )
                .padding()

                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Recents Section
                        if !recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recents")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(recentSearches) { recent in
                                    ItemRow(title: recent.name, icon: "magnifyingglass")
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            query = recent.name              // 1. autofill
                                            onRecentSelected(recent)         // 2. pass event up
                                        }
                                }

                            }
                        }
                        
                        // Saved Places Section
                        if !savedPlaces.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Saved Places")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                ForEach(savedPlaces) { place in
                                    ItemRow(title: place.name, emoji: place.emoji)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            onSavedPlaceSelected(place)
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
    // Add other relevant data like coordinates if needed
}

