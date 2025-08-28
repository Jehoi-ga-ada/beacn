//
//  ReportLocationPickerView.swift
//  BEACN
//
//  Created by Jessica Lynn on 29/08/25.
//


import SwiftUI
import MapKit

struct ReportLocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D
    
    let emoji: String
    let onConfirm: (CLLocationCoordinate2D) -> Void
    
    init(userLocation: CLLocationCoordinate2D,
         emoji: String,
         onConfirm: @escaping (CLLocationCoordinate2D) -> Void) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        _region = State(initialValue: MKCoordinateRegion(center: userLocation, span: span))
        _selectedCoordinate = State(initialValue: userLocation)
        self.emoji = emoji
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region,
                interactionModes: [.all],
                showsUserLocation: true)
                .ignoresSafeArea()
                .onChange(of: region.center.latitude) { _ in
                    selectedCoordinate = region.center
                }
                .onChange(of: region.center.longitude) { _ in
                    selectedCoordinate = region.center
                }
            
            VStack {
                Spacer()
                ReportPinView(emoji: emoji)
                    .offset(y: -20) // lift it so stick tip aligns with center
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .fontWeight(.medium)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                    
                    Button("Report") {
                        onConfirm(selectedCoordinate)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }
}
