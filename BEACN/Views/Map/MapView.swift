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
//    @State private var selectedReport: Report?
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
                                    viewModel.selectedReport = report
                                    viewModel.showReportCard = true
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
                                viewModel.searchQuery = ""
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
                                    onLongPress: { place in
                                        viewModel.placeToDelete = place
                                        viewModel.showDeletePlaceAlert = true
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
                if viewModel.showReportCard, let selectedReport = viewModel.selectedReport {
                    let reportView = selectedReport.toReportView()
                    VStack {
                        Spacer()
                        ReportCardView(
                            report: reportView,
                            onToggleUpvote: {
                                let upvoteService = UpvoteService()
                                let reportService = ReportService()
                                
                                _ = try await upvoteService.toggleUpvote(reportId: selectedReport.id)
                                
                                //TODO: Bugging upvotes
                                let updatedReports = try await reportService.getAllReports()
                                if let updated = updatedReports.first(where: { $0.id == selectedReport.id }) {
                                    print("🔄 Updated count:", updated.reportUpvoteCount?.first?.count ?? 0)
                                    return updated.reportUpvoteCount?.first?.count ?? reportView.upvotes
                                }
                                
                                return reportView.upvotes // fallback
                            }
                        )                        .transition(.move(edge: .bottom))
                    }
                    .background(
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.showReportCard = false
                            }
                    )
                    .zIndex(3)
                }


                // Delete place confirmation
                if viewModel.showDeletePlaceAlert, let placeToDelete = viewModel.placeToDelete {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            // Place info section
                            HStack(spacing: 12) {
                                Text(placeToDelete.emoji)
                                    .font(.system(size: 32))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Saved Place")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(placeToDelete.name)
                                        .font(.title2)
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            Button("Remove from Saved Places") {
                                viewModel.deletePlace(placeToDelete)
                            }
                            .foregroundColor(.secondary)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 35))
                        .padding(.horizontal, 20)
                        .shadow(radius: 10, y: 5)
                    }
                    .background(
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.showDeletePlaceAlert = false
                                viewModel.placeToDelete = nil
                            }
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(4)
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
                    let response = try await viewModel.reportService.createReport(
                        categoryName: viewModel.selectedSubcategory?.name ?? "Fallback",
                        latitude: coord.latitude,
                        longitude: coord.longitude
                    )
                    print(response)
                }
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




#Preview {
    MapView(viewModel: MapVM(coordinator: AppCoordinator()))
}
