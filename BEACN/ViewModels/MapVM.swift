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
        center: CLLocationCoordinate2D(latitude: -6.2088, longitude: 106.8456),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var searchQuery: String = ""
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedPlace: Place?
    @Published var showPlacePinpoint: Bool = false
    @Published var savedPlaces: [Place] = []

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
    
    func fetchSavedPlaces() {
        Task {
            do {
                let apiPlaces = try await savedPlaceService.getAllSavedPlaces()
                DispatchQueue.main.async {
                    self.savedPlaces = apiPlaces.map { $0.toPlace() }
                }
            } catch {
                print("❌ Failed to fetch saved places:", error)
            }
        }
    }

    func selectSearchResult(_ item: MKMapItem) {
        guard let coord = item.placemark.location?.coordinate else { return }
        let newPlace = Place(
            id: UUID().uuidString,
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
        
        if let index = savedPlaces.firstIndex(where: { $0.id == editingPlace.id }) {
            savedPlaces[index] = updatedPlace
        }
        
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
        
        locationService.$currentLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                self?.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
            .store(in: &cancellables)
        fetchSavedPlaces()
    }
    
    func toggleOrbit() {
        withAnimation(.spring()) {
            showOrbit.toggle()
        }
    }
    
    func addPlace(_ place: Place) {
        Task {
            do {
                let saved = try await savedPlaceService.createSavedPlace(
                    type: "custom", // wasnt assigned anything
                    name: place.name,
                    latitude: place.latitude,
                    longitude: place.longitude,
                    emoji: place.emoji
                )
                DispatchQueue.main.async {
                    self.savedPlaces.append(saved.toPlace())
                }
                fetchSavedPlaces()
            } catch {
                print("❌ Failed to save place:", error)
            }
        }
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
    func centerOnUser() {
        if let currentLocation = locationService.currentLocation {
            withAnimation {
                region = MKCoordinateRegion(
                    center: currentLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}

extension SavedPlace {
    func toPlace() -> Place {
        Place(
            id: id,
            uuid: userId,
            latitude: latitude,
            longitude: longitude,
            name: name,
            emoji: emoji
        )
    }
}
