//
//  MapScreen.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//
// MapScreen.swift

import SwiftUI
import MapLibre

struct MapScreen: View {
    @StateObject private var viewModel = MapLibreWrapperModel()
    @StateObject private var locationManager = LocationManager()
    @State private var selectedStyle: MapStyle = .voyager
    @State private var showMapControls = true
    
    var body: some View {
        ZStack {
            // MapView
            MLNMapViewWrapper(
                viewModel: viewModel,
                styleUrl: selectedStyle.rawValue,
                inset: .init(
                    insets: .init(top: 0, left: 0, bottom: 0, right: 0),
                    animated: false
                ),
                trackingMode: .none,
                showsUserLocation: true
            )
            .ignoresSafeArea()
            .onAppear {
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
            }
            .onDisappear {
                locationManager.stopUpdatingLocation()
                locationManager.stopUpdatingHeading()
            }
            
            // Map Controls
            if showMapControls {
                VStack {
                    HStack {
                        Spacer()
                        
                        MapControlsView(
                            viewModel: viewModel,
                            onUserLocationTap: {
                                if let location = locationManager.location?.coordinate {
                                    viewModel.centerMap(on: location, zoom: 15, animated: true)
                                }
                            },
                            onZoomInTap: {
                                viewModel.mapView?.zoomLevel += 1
                            },
                            onZoomOutTap: {
                                viewModel.mapView?.zoomLevel -= 1
                            },
                            onCompassTap: {
                                viewModel.mapView?.resetNorth()
                            }
                        )
                    }
                    
                    Spacer()
                    
                    HStack {
                        // Map style selector
                        Menu {
                            Picker("Map Style", selection: $selectedStyle) {
                                ForEach(MapStyle.allCases, id: \.self) { style in
                                    Text(style.displayName).tag(style)
                                }
                            }
                        } label: {
                            Image(systemName: "map")
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding()
                        
                        Spacer()
                        
                        // Additional controls can go here
                    }
                }
            }
        }
    }
}
