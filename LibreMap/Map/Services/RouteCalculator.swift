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
                        via waypoints: [CLLocationCoordinate2D] = [],
                        profile: RouteProfile = .driving,
                        completion: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        
        // Construct the coordinates string
        var coordinateString = "\(start.longitude),\(start.latitude);"
        
        // Add any waypoints
        for waypoint in waypoints {
            coordinateString += "\(waypoint.longitude),\(waypoint.latitude);"
        }
        
        // Add the destination
        coordinateString += "\(end.longitude),\(end.latitude)"
        
        // Construct the URL
        var components = URLComponents(string: "\(baseURL)/\(profile.rawValue)")
        components?.queryItems = [
            URLQueryItem(name: "access_token", value: apiKey),
            URLQueryItem(name: "geometries", value: "geojson"),
            URLQueryItem(name: "overview", value: "full"),
            URLQueryItem(name: "alternatives", value: "false"),
            URLQueryItem(name: "steps", value: "true")
        ]
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "RouteCalculator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = coordinateString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "RouteCalculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let geometry = route["geometry"] as? [String: Any],
                   let coordinates = geometry["coordinates"] as? [[Double]] {
                    
                    // Convert to CLLocationCoordinate2D array
                    let routeCoordinates = coordinates.map { coord -> CLLocationCoordinate2D in
                        // GeoJSON uses [longitude, latitude] order
                        return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
                    }
                    
                    completion(.success(routeCoordinates))
                } else {
                    completion(.failure(NSError(domain: "RouteCalculator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse route data"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // Route profiles
    enum RouteProfile: String {
        case driving = "driving"
        case walking = "walking"
        case cycling = "cycling"
        case drivingTraffic = "driving-traffic"
    }
}
