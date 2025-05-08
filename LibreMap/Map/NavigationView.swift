//
//  NavigationView.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import SwiftUI
import MapLibre
import CoreLocation

struct MapNavigationView: View {
    @StateObject private var viewModel = MapLibreWrapperModel()
    @StateObject private var navigationService = NavigationService()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedStyle: MapStyle = .voyager
    @State private var showNavigationOverlay = false
    
    // For demonstration purposes, let's define start and end coordinates
    private let startCoordinate = CLLocationCoordinate2D(latitude: 40.392918, longitude: 71.796147)
    private let endCoordinate = CLLocationCoordinate2D(latitude: 40.380204, longitude: 71.768693)
    
    var body: some View {
        ZStack {
            // Map View
            MLNMapViewWrapper(
                viewModel: viewModel,
                camera: navigationService.isNavigating && navigationService.carPosition != nil ?
                    MapCamera.following(
                        coordinate: navigationService.carPosition!,
                        distance: 300,
                        pitch: 45,
                        heading: navigationService.carHeading
                    ) : nil,
                styleUrl: selectedStyle.rawValue,
                inset: .init(
                    insets: .init(top: 100, left: 0, bottom: 200, right: 0),
                    animated: true
                ),
                trackingMode: navigationService.isNavigating ? Optional.none : .followWithHeading,
                showsUserLocation: !navigationService.isNavigating
            )
            .ignoresSafeArea()
            .onAppear {
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                
                // For demo purposes, automatically calculate and draw a route
                calculateAndDrawRoute()
            }
            .onDisappear {
                locationManager.stopUpdatingLocation()
                locationManager.stopUpdatingHeading()
                navigationService.stopNavigation()
            }
            
            // Car marker when navigating
            if navigationService.isNavigating, let carPosition = navigationService.carPosition {
                CarMarkerView(position: carPosition, heading: navigationService.carHeading)
                    .frame(width: 36, height: 36)
                    .position(
                        x: viewModel.mapView?.convert(carPosition, toPointTo: nil).x ?? 0,
                        y: viewModel.mapView?.convert(carPosition, toPointTo: nil).y ?? 0
                    )
            }
            
            // Navigation controls
            if !navigationService.isNavigating {
                VStack {
                    Spacer()
                    
                    Button(action: startNavigation) {
                        Text("Start Navigation")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                }
            } else {
                NavigationOverlayView(
                    navigationService: navigationService,
                    onEndNavigation: {
                        navigationService.stopNavigation()
                    }
                )
            }
        }
    }
    
    private func calculateAndDrawRoute() {
        // Create a RouteCalculator
        let routeCalculator = RouteCalculator(apiKey: "YOUR_API_KEY")
        
        Task {
            // Get route coordinates
            let coordinates = await routeCalculator.calculateRoute(
                from: startCoordinate,
                to: endCoordinate
            )
            
            Task { @MainActor in
                // Add the route as a polyline to the map
                let polyline = viewModel.addPolyline(
                    coordinates: coordinates,
                    title: "Navigation Route",
                    color: .blue,
                    width: 5.0
                )
                
                // Focus the map on the route
                viewModel.focusOnPolyline(id: polyline.id)
            }
        }
    }
    
    private func startNavigation() {
        guard let userLocation = locationManager.location,
              let polyline = viewModel.savedPolylines.first else {
            return
        }
        
        navigationService.startNavigation(along: polyline, from: userLocation)
    }
}

#Preview {
    MapNavigationView()
}
