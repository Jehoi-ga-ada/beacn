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
    @Published var selectedReport: Report? = nil
    @Published var showReportCard: Bool = false
    @Published var pendingPlace: Place? = nil
    @Published var showSavePlaceSheet: Bool = false
    @Published var showEditPlaceSheet: Bool = false
    @Published var editingPlace: Place? = nil
    @Published var editPlaceName: String = ""
    @Published var selectedEmoji: String = "📍"
    @Published var showMaxPlacesAlert = false
    @Published var showDeletePlaceAlert = false
    @Published var placeToDelete: Place? = nil
    
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
        
        Task {
            do {
                // Save to persistent storage using the service
                let saved = try await savedPlaceService.updateSavedPlace(
                    id: editingPlace.id,
                    name: updatedPlace.name,
                    latitude: updatedPlace.latitude,
                    longitude: updatedPlace.longitude,
                    emoji: updatedPlace.emoji
                )
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    if let index = self.savedPlaces.firstIndex(where: { $0.id == editingPlace.id }) {
                        self.savedPlaces[index] = updatedPlace // Use updatedPlace to keep emoji
                    }
                    
                    // Reset form state
                    self.editingPlace = nil
                    self.editPlaceName = ""
                    self.selectedEmoji = "📍"
                    self.showEditPlaceSheet = false
                }
                
                // Refresh from server to ensure consistency
                fetchSavedPlaces()
                
            } catch {
                print("❌ Failed to update place:", error)
                // Optionally handle error in UI
                DispatchQueue.main.async {
                    // Could show an error alert here
                }
            }
        }
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
        if savedPlaces.count >= 3 {
            self.showMaxPlacesAlert = true
            return
        }
        
        Task {
            do {
                let saved = try await savedPlaceService.createSavedPlace(
                    type: "custom",
                    name: place.name,
                    latitude: place.latitude,
                    longitude: place.longitude,
                    emoji: place.emoji
                )
                DispatchQueue.main.async {
                    let newPlace = saved.toPlace()
                    self.savedPlaces.append(newPlace)
                    
                    // Auto-trigger edit mode for the newly created place
                    self.startEditingPlace(newPlace)
                }
                fetchSavedPlaces()
            } catch {
                print("❌ Failed to save place:", error)
            }
        }
    }
    
    func deletePlace(_ place: Place) {
        Task {
            do {
                let success = try await savedPlaceService.deleteSavedPlace(id: place.id)
                if success {
                    DispatchQueue.main.async {
                        self.savedPlaces.removeAll { $0.id == place.id }
                        self.showDeletePlaceAlert = false
                        self.placeToDelete = nil
                    }
                }
            } catch {
                print("⌐ Failed to delete place:", error)
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
