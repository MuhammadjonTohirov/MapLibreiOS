//
//  RouteCalculator.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//
// RouteCalculator.swift

import Foundation
import MapLibre

class RouteCalculator {
    private let apiKey: String
    private let baseURL = "https://api.mapbox.com/directions/v5/mapbox"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // Calculate a route between two points
    func calculateRoute(from start: CLLocationCoordinate2D,
                        to end: CLLocationCoordinate2D,
                        via waypoints: [CLLocationCoordinate2D] = []) async -> [CLLocationCoordinate2D] {
        var route = [start] + waypoints + [end]
        
        return (try? await RouteTariffCalcGateway().calculateRouteAndTariffs(req: .init(coords: route.map({.init(lat: $0.latitude, lng: $0.longitude)}), address: nil)))?.map?.routings.compactMap { item in
            CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
        } ?? []
    }
    
    // Route profiles
    enum RouteProfile: String {
        case driving = "driving"
        case walking = "walking"
        case cycling = "cycling"
        case drivingTraffic = "driving-traffic"
    }
}
