//
//  MapVM.swift
//  BEACN
//
//  Created by Jessica Lynn on 27/08/25.
//

import Foundation
import MapKit
import SwiftUI
import Combine

class MapVM: ObservableObject {
    let coordinator: AppCoordinator
    private let locationService: LocationService
    let reportService: ReportService = ReportService()
    let savedPlaceService: SavedPlaceService = SavedPlaceService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456), // fallback: Jakarta
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var searchQuery: String = ""
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedPlace: Place?
    @Published var showPlacePinpoint: Bool = false
    @Published var savedPlaces: [Place] = [
        Place(id: 1, uuid: "user-123", latitude: -6.2088, longitude: 106.8456, name: "Home", emoji: "🏠"),
        Place(id: 2, uuid: "user-123", latitude: -6.1214, longitude: 106.7741, name: "Campus", emoji: "🎓"),
        Place(id: 3, uuid: "user-123", latitude: -6.1754, longitude: 106.8272, name: "Monas", emoji: "🗼"),
//        Place(id: 4, uuid: "user-123", latitude: 37.7879, longitude: -122.4074,name: "Union Square", emoji: "📍")
//        Place(id: 5, uuid: "user-123", latitude: 38.7879, longitude: -122.4074,name: "Whut", emoji: "📍")
        //safe area adalah nambah dari 2 ke 3
    ]

    @Published var recentSearches: [RecentSearch] = [
        RecentSearch(name: "Pondok Indah Residence"),
        RecentSearch(name: "Jalan Damai Indah"),
        RecentSearch(name: "Damai Indah Residence")
    ]
    
    @Published var showReportSheet: Bool = false
    @Published var selectedReportType: ReportType? = nil
    @Published var selectedSubcategory: ReportSubcategory? = nil
    
    @Published var showLocationPicker: Bool = false
    

    @Published var pendingPlace: Place? = nil
    @Published var showSavePlaceSheet: Bool = false
    
    @Published var showEditPlaceSheet: Bool = false
    @Published var editingPlace: Place? = nil
    @Published var editPlaceName: String = ""
    @Published var selectedEmoji: String = "📍"

    func selectSearchResult(_ item: MKMapItem) {
        guard let coord = item.placemark.location?.coordinate else { return }
        let newPlace = Place(
            id: Int.random(in: 1000...9999),
            uuid: "user-123", // later replace with logged-in user's uuid
            latitude: coord.latitude,
            longitude: coord.longitude,
            name: item.name ?? "Unnamed Place",
            emoji: "📍"
        )
        
        self.pendingPlace = newPlace
        self.region = MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        self.showSavePlaceSheet = true
    }
    
    func startEditingPlace(_ place: Place) {
        editingPlace = place
        editPlaceName = place.name
        selectedEmoji = place.emoji
        showEditPlaceSheet = true
    }

    func saveEditedPlace() {
        guard let editingPlace = editingPlace else { return }
        
        let updatedPlace = Place(
            id: editingPlace.id,
            uuid: editingPlace.uuid,
            latitude: editingPlace.latitude,
            longitude: editingPlace.longitude,
            name: editPlaceName.isEmpty ? "Unnamed Place" : editPlaceName,
            emoji: selectedEmoji
        )
        
        // Find and replace the place in savedPlaces
        if let index = savedPlaces.firstIndex(where: { $0.id == editingPlace.id }) {
            savedPlaces[index] = updatedPlace
        }
        
        // Clear editing state
        self.editingPlace = nil
        self.editPlaceName = ""
        self.selectedEmoji = "📍"
        self.showEditPlaceSheet = false
    }

    
    // MARK: - Orbit Mechanism
    @Published var showOrbit: Bool = false
    
    
    /// Computed angles for orbit placement (half-circle layout)
    var orbitAngles: [Double] {
        guard savedPlaces.count > 1 else { return [0] }
        return (0..<savedPlaces.count).map { index in
            Double(index) / Double(savedPlaces.count - 1) * .pi
        }
    }
    
    init(coordinator: AppCoordinator, locationService: LocationService = LocationService()) {
        self.coordinator = coordinator
        self.locationService = locationService
        
        // 👇 Subscribe to location updates
        locationService.$currentLocation
            .compactMap { $0 }
            .first() // only recenter once at app start
            .sink { [weak self] location in
                self?.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
            .store(in: &cancellables)
    }
    
    func toggleOrbit() {
        withAnimation(.spring()) {
            showOrbit.toggle()
        }
    }
    
    func addPlace(_ place: Place) {
        savedPlaces.append(place)
    }
    
    func searchPlaces() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let items = response?.mapItems else { return }
            DispatchQueue.main.async {
                self.searchResults = items
                if let first = items.first {
                    self.region = MKCoordinateRegion(
                        center: first.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
    func focusOn(_ place: Place) {
        region = MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}
