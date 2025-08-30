//
//  MapView.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapVM
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var isSearching: Bool = false
    @FocusState private var searchFieldFocused: Bool
    @StateObject var reportStore = ReportStore()
    @State private var selectedReport: Report?
    @State private var showingCamera = false
    @State private var capturedPhoto: UIImage?
    
    var annotations: [MapAnnotationItem] {
        let placeItems = viewModel.savedPlaces.map {
            MapAnnotationItem(coordinate: $0.coordinate, type: .place($0))
        }
        
        let pendingItems = viewModel.pendingPlace.map {
            [MapAnnotationItem(coordinate: $0.coordinate, type: .place($0))]
        } ?? []
        
        let reportItems = reportStore.reports.compactMap { report in
            if let lat = report.latitude, let lng = report.longitude {
                return MapAnnotationItem(
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    type: .report(report)
                )
            }
            return nil
        }
        
        return placeItems + pendingItems + reportItems
    }


    
    var body: some View {
        NavigationStack {
            //overlay map
            ZStack(alignment: .top) {
                Map(
                    coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    userTrackingMode: $trackingMode,
                    annotationItems: annotations
                ) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        switch item.type {
                        case .place(let place):
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

                        case .report(let report):
                            ReportPinView(emoji: report.emoji)
                                .onTapGesture {
                                    selectedReport = report
                                }
                        }
                    }
                }

                .ignoresSafeArea()
                .task {
                    await reportStore.fetchAllReports()
                }
                
                //custom header
                if !isSearching {
                    VStack{
                        HStack {
                            NavigationLink(destination: MyProfileView()){
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color(hex: "005DAD"))
                                    .font(.title2)
                            }
                            Spacer()
                            Text("beacn")
                                .font(.custom("LexendDeca-Regular", size: 22))
                                .foregroundStyle(beaconGradient)
                            Spacer()
                            Button { } label: {
                                Image(systemName: "tray.fill")
                                    .foregroundStyle(Color(hex: "005DAD"))
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .padding(.top, 60)
                        .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 40))
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .top)
                        Spacer()
                    }
                }
                
                //content under header
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
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.searchResults, id: \.self) { item in
                                    Button(action: {
                                        viewModel.selectSearchResult(item)
                                        viewModel.searchResults = []
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name ?? "Unknown")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            Text(item.placemark.title ?? "")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                        .padding(.top, 10)
                    }

                }
                .padding(.top, 50)
                
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            withAnimation {
                                trackingMode = .follow
                                viewModel.centerOnUser()
                            }
                        }) {
                            Image(systemName: "location")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .padding(12)
                                .foregroundColor(.black)
                                .background(Color.white.opacity(0.75))
                                .clipShape(RoundedRectangle(cornerRadius: 17))
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal, 25)
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
                                    onAdd: {
                                        isSearching = true
                                    },
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
                        HStack{
                            Button(action: { showingCamera = true }) {
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(18)
                                    .foregroundStyle(Color.white)
                                    .frame(width: 70, height: 70)
                                    .background(cameraGradient)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
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
                                    SubcategorySheetView(
                                        type: selectedType,
                                        onBack: { viewModel.selectedReportType = nil },
                                        onSelect: { sub in
                                            viewModel.selectedReportType = nil
                                            viewModel.showReportSheet = false
                                            viewModel.selectedSubcategory = sub
                                            
                                            if let current = viewModel.region.center as CLLocationCoordinate2D? {
                                                viewModel.showLocationPicker = true
                                            }
                                        }
                                    )
                                    .presentationDetents([.medium])
                                } else {
                                    ReportSheetView { type in
                                        viewModel.selectedReportType = type
                                    }
                                    .presentationDetents([.medium])
                                }
                            }
                        }
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "FF8300"), Color(hex: "2877C0")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .cornerRadius(50)
                    }
                    .padding(.horizontal, 20)
                }
                if isSearching {
                    SearchOverlayView(
                        viewModel: viewModel,
                        isSearching: $isSearching,
                        searchFieldFocused: $searchFieldFocused,
                        query: $viewModel.searchQuery
                    )
                    .transition(.move(edge: .top))
                    .zIndex(1)
                }

                if viewModel.showSavePlaceSheet, let pending = viewModel.pendingPlace {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Save this place?")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 20)
                                
                            HStack {
                                Button("Cancel") {
                                    viewModel.pendingPlace = nil
                                    viewModel.showSavePlaceSheet = false
                                }
                                .foregroundColor(.red)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 40)
                                .background(.white)
                                .fontWeight(.medium)
                                .shadow(radius: 5)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    
                                Spacer()
                                    
                                Button("Save") {
                                    viewModel.addPlace(pending)
                                    viewModel.pendingPlace = nil
                                    viewModel.showSavePlaceSheet = false
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 50)
                                .background(Color(hex: "005DAD"))
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                                .shadow(radius: 5)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                        .background(Color.white.opacity(0.6))
                        .background(.ultraThinMaterial)
                        .cornerRadius(30)
                        .padding(.horizontal, 16)
                        .shadow(radius: 10)
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                }
                if viewModel.showMaxPlacesAlert {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                viewModel.showMaxPlacesAlert = false
                            }
                        }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white)
                        VStack(alignment: .center, spacing: 10) {
                            Text("You’ve reached maximum slots of saved places on Free Plan.")
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding(.horizontal, 23)
                            
                            VStack {
                                Button("No thanks") {
                                    viewModel.showMaxPlacesAlert = false
                                }
                                .foregroundColor(.gray)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 40)
                                .background(.white)
                                .fontWeight(.medium)
                                .shadow(radius: 5)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                                                
                                Button("Upgrade") {
                                    
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal, 60)
                                .background(Color(hex: "005DAD"))
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                                .shadow(radius: 5)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 250)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showLocationPicker) {
            ReportLocationPickerView(
                userLocation: viewModel.region.center,
                emoji: viewModel.selectedSubcategory?.emoji ?? "📍"
            ) { coord in
                print("User placed report at: \(coord.latitude), \(coord.longitude)")
                Task {
                    let response = try await viewModel.reportService.createReport(categoryName: viewModel.selectedSubcategory?.name ?? "Fallback", latitude: coord.latitude, longitude: coord.latitude)
                    print(response)
                }
                // TODO: Save report with coord + selectedSubcategory
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraCaptureView(
                onPhotoCapture: { image in
                    capturedPhoto = image
                    print("📸 Captured photo from MapView")
                },
                onNavigateNext: {
                    showingCamera = false
                    print("➡️ Move to next step after camera (if needed)")
                }
            )
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
                    onSubmit: { viewModel.searchPlaces() }
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

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    
    enum AnnotationType {
        case place(Place)
        case report(Report)
    }
}


#Preview {
    MapView(viewModel: MapVM(coordinator: AppCoordinator()))
}
