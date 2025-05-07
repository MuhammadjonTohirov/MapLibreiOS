//
//  MapPolylineExampleView.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import SwiftUI
import MapLibre
import CoreLocation

struct MapRouteExampleView: View {
    @StateObject private var viewModel = MapLibreWrapperModel()
    @State private var startAddress = "New York, NY"
    @State private var endAddress = "Boston, MA"
    @State private var isCalculating = false
    @State private var errorMessage: String? = nil
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    @State private var routeColor: UIColor = .blue
    
    // Sample locations for quick selection
    private let predefinedLocations = [
        "New York, NY",
        "Boston, MA",
        "Washington, DC",
        "Chicago, IL",
        "San Francisco, CA",
        "Los Angeles, CA",
        "Seattle, WA",
        "Miami, FL"
    ]
    
    // For map control
    private let routeColors: [UIColor] = [.blue, .red, .green, .purple, .orange]
    
    // API Key for geocoding and routing
    private let apiKey = "pk.eyJ1IjoibXVyaG9odW4iLCJhIjoiY2swcDFxODk2MGZkYTNjcXJzcmVhN21zcSJ9.NIcKRHBQ030kqdTDaVT3gQ" // Replace with your actual API key
    
    var body: some View {
        ZStack {
            // Map View
            MLNMapViewWrapper(
                viewModel: viewModel,
                styleUrl: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
                inset: .init(
                    insets: .init(top: 0, left: 0, bottom: 0, right: 0),
                    animated: false
                ),
                showsUserLocation: true
            )
            .ignoresSafeArea()
            
            // Top panel for location inputs
            VStack {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                        
                        TextField("Start location", text: $startAddress)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                        
                        Button(action: { showStartPicker = true }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        
                        TextField("Destination", text: $endAddress)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                        
                        Button(action: { showEndPicker = true }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        // Color selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<routeColors.count, id: \.self) { index in
                                    Circle()
                                        .fill(Color(routeColors[index]))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(routeColor == routeColors[index] ? Color.white : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            routeColor = routeColors[index]
                                        }
                                }
                            }
                        }
                        .frame(width: 200, height: 40)
                        
                        Spacer()
                        
                        Button(action: calculateRoute) {
                            if isCalculating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Calculate Route")
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(isCalculating)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
                
                Spacer()
                
                // Bottom panel with controls
                HStack {
                    Button(action: { viewModel.clearAllPolylines() }) {
                        Text("Clear Routes")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    if !viewModel.savedPolylines.isEmpty, let lastPolyline = viewModel.savedPolylines.last {
                        Button(action: {
                            viewModel.focusOnPolyline(id: lastPolyline.id)
                        }) {
                            Text("Focus on Route")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .actionSheet(isPresented: $showStartPicker) {
            ActionSheet(
                title: Text("Select Start Location"),
                buttons: predefinedLocationsButtons { location in
                    startAddress = location
                }
            )
        }
        .actionSheet(isPresented: $showEndPicker) {
            ActionSheet(
                title: Text("Select Destination"),
                buttons: predefinedLocationsButtons { location in
                    endAddress = location
                }
            )
        }
    }
    
    // Helper to create location buttons for action sheets
    private func predefinedLocationsButtons(action: @escaping (String) -> Void) -> [ActionSheet.Button] {
        var buttons = predefinedLocations.map { location in
            ActionSheet.Button.default(Text(location)) { action(location) }
        }
        buttons.append(.cancel())
        return buttons
    }
    
    // Calculate the route between start and end points
    private func calculateRoute() {
        guard !startAddress.isEmpty, !endAddress.isEmpty else {
            errorMessage = "Please enter both start and destination addresses"
            return
        }
        
        errorMessage = nil
        isCalculating = true
        
        // First, geocode the start address
        geocodeAddress(startAddress) { startResult in
            switch startResult {
            case .success(let startCoordinate):
                // Then, geocode the end address
                geocodeAddress(endAddress) { endResult in
                    switch endResult {
                    case .success(let endCoordinate):
                        calculateRouteBetween(start: startCoordinate, end: endCoordinate)
                    case .failure(let error):
                        DispatchQueue.main.async {
                            isCalculating = false
                            errorMessage = "Error finding destination: \(error.localizedDescription)"
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isCalculating = false
                    errorMessage = "Error finding start location: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Geocode an address to get coordinates
    private func geocodeAddress(_ address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                completion(.failure(NSError(domain: "GeocodeError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No location found for address"])))
                return
            }
            
            completion(.success(location.coordinate))
        }
    }
    
    // Calculate a route between two coordinates
    private func calculateRouteBetween(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        // Create a RouteCalculator to compute the route
        let routeCalculator = RouteCalculator(apiKey: apiKey)
        
        // Calculate the route
        Task {
            let coordinates = await routeCalculator.calculateRoute(from: start, to: end)
            
            Task { @MainActor in
                isCalculating = false
                
                // Add the route as a polyline to the map
                let polyline = viewModel.addPolyline(
                    coordinates: coordinates,
                    title: "\(startAddress) to \(endAddress)",
                    color: routeColor,
                    width: 5.0
                )
                
                // Focus the map on the route
                viewModel.focusOnPolyline(id: polyline.id)
            }
        }
        
    }
}

// Add this to preview the view
struct MapRouteExampleView_Previews: PreviewProvider {
    static var previews: some View {
        MapRouteExampleView()
    }
}
