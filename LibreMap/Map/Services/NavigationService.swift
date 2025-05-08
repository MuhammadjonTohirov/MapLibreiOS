//
//  NavigationService.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import MapLibre
import Combine
import CoreLocation

class NavigationService: ObservableObject {
    @Published var isNavigating: Bool = false
    @Published var currentDistance: Double = 0
    @Published var totalDistance: Double = 0
    @Published var remainingDistance: Double = 0
    @Published var currentSpeed: Double = 0
    @Published var estimatedTimeRemaining: TimeInterval = 0
    @Published var currentInstruction: String = ""
    @Published var upcomingManeuver: String = ""
    @Published var distanceToNextManeuver: Double = 0
    
    private var timer: Timer?
    private var currentLocation: CLLocation?
    private var route: MapPolyline?
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var currentCoordinateIndex: Int = 0
    
    // The position of the animated car
    @Published var carPosition: CLLocationCoordinate2D?
    @Published var carHeading: Double = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {}
    
    func startNavigation(along route: MapPolyline, from location: CLLocation) {
        guard !route.coordinates.isEmpty else { return }
        
        self.route = route
        self.routeCoordinates = route.coordinates
        self.totalDistance = route.distance
        self.remainingDistance = route.distance
        self.isNavigating = true
        
        // Find closest point on route to current location
        let startCoordinate = findClosestPointOnRoute(to: location.coordinate)
        self.carPosition = startCoordinate.coordinate
        self.currentLocation = location
        self.currentCoordinateIndex = startCoordinate.index
        
        // Start navigation simulation timer
        startNavigationSimulation()
    }
    
    func stopNavigation() {
        self.isNavigating = false
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func startNavigationSimulation() {
        timer?.invalidate()
        
        // Update every 100ms for smooth animation
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateNavigation()
        }
    }
    
    private func updateNavigation() {
        guard let route = route, isNavigating, currentCoordinateIndex < routeCoordinates.count - 1 else {
            if currentCoordinateIndex >= routeCoordinates.count - 1 {
                // We've reached the destination
                stopNavigation()
            }
            return
        }
        
        // Calculate progress
        simulateMovementAlongRoute()
        
        // Update remaining distance
        let traveledDistance = calculateDistanceTraveled()
        remainingDistance = totalDistance - traveledDistance
        
        // Update estimated time remaining (assuming average speed of 50 km/h)
        let averageSpeedMPS = 13.89 // 50 km/h in meters per second
        estimatedTimeRemaining = remainingDistance / averageSpeedMPS
        
        // Update navigation instructions
        updateNavigationInstructions()
    }
    
    private func calculateDistanceTraveled() -> Double {
        guard currentCoordinateIndex > 0, routeCoordinates.count > 1 else { return 0 }
        
        var distance: Double = 0
        
        // Calculate distance for completed segments
        for i in 0..<currentCoordinateIndex {
            let start = CLLocation(latitude: routeCoordinates[i].latitude,
                                  longitude: routeCoordinates[i].longitude)
            let end = CLLocation(latitude: routeCoordinates[i+1].latitude,
                                longitude: routeCoordinates[i+1].longitude)
            distance += start.distance(from: end)
        }
        
        return distance
    }
    
    private func simulateMovementAlongRoute() {
        guard currentCoordinateIndex < routeCoordinates.count - 1 else { return }
        
        // Get current and next coordinates
        let current = routeCoordinates[currentCoordinateIndex]
        let next = routeCoordinates[currentCoordinateIndex + 1]
        
        // Calculate heading
        carHeading = current.direction(to: next).wrap(min: 0, max: 360)
        
        // Move car toward next coordinate
        let stepDistance: Double = 2.0 // meters per step
        let totalSegmentDistance = CLLocation(latitude: current.latitude, longitude: current.longitude)
            .distance(from: CLLocation(latitude: next.latitude, longitude: next.longitude))
        
        if totalSegmentDistance <= stepDistance {
            // We've reached the next coordinate, advance
            currentCoordinateIndex += 1
            carPosition = next
        } else {
            // Interpolate position between current and next
            let fraction = stepDistance / totalSegmentDistance
            let newLat = current.latitude + (next.latitude - current.latitude) * fraction
            let newLng = current.longitude + (next.longitude - current.longitude) * fraction
            
            // Update intermediate coordinates in the array
            routeCoordinates[currentCoordinateIndex] = CLLocationCoordinate2D(latitude: newLat, longitude: newLng)
            carPosition = routeCoordinates[currentCoordinateIndex]
        }
    }
    
    private func findClosestPointOnRoute(to coordinate: CLLocationCoordinate2D) -> (coordinate: CLLocationCoordinate2D, index: Int) {
        var closestDistance = Double.greatestFiniteMagnitude
        var closestCoordinate = routeCoordinates.first!
        var closestIndex = 0
        
        for (index, routeCoord) in routeCoordinates.enumerated() {
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: CLLocation(latitude: routeCoord.latitude, longitude: routeCoord.longitude))
            
            if distance < closestDistance {
                closestDistance = distance
                closestCoordinate = routeCoord
                closestIndex = index
            }
        }
        
        return (closestCoordinate, closestIndex)
    }
    
    private func updateNavigationInstructions() {
        // Simple algorithm to determine navigation instructions based on upcoming route segments
        guard currentCoordinateIndex < routeCoordinates.count - 2 else {
            currentInstruction = "You have reached your destination"
            upcomingManeuver = ""
            distanceToNextManeuver = 0
            return
        }
        
        // Look ahead on the route to find significant turns
        var lookaheadIndex = currentCoordinateIndex
        var lastHeading = carHeading
        
        while lookaheadIndex < routeCoordinates.count - 2 {
            let coord1 = routeCoordinates[lookaheadIndex]
            let coord2 = routeCoordinates[lookaheadIndex + 1]
            let heading = coord1.direction(to: coord2).wrap(min: 0, max: 360)
            
            let headingDifference = abs(heading.difference(from: lastHeading))
            
            if headingDifference > 30 {
                // We found a significant turn
                // Calculate distance to this maneuver
                var distanceToManeuver: Double = 0
                for i in currentCoordinateIndex..<lookaheadIndex {
                    let start = CLLocation(latitude: routeCoordinates[i].latitude,
                                          longitude: routeCoordinates[i].longitude)
                    let end = CLLocation(latitude: routeCoordinates[i+1].latitude,
                                        longitude: routeCoordinates[i+1].longitude)
                    distanceToManeuver += start.distance(from: end)
                }
                
                distanceToNextManeuver = distanceToManeuver
                
                // Determine turn direction
                let direction = getTurnDirection(headingDifference: heading.difference(from: lastHeading))
                upcomingManeuver = "\(direction) in \(Int(distanceToManeuver)) meters"
                currentInstruction = "Continue straight for \(Int(distanceToManeuver)) meters"
                
                return
            }
            
            lastHeading = heading
            lookaheadIndex += 1
        }
        
        // If no turns found
        currentInstruction = "Continue straight"
        upcomingManeuver = "Proceed to destination"
        distanceToNextManeuver = remainingDistance
    }
    
    private func getTurnDirection(headingDifference: Double) -> String {
        let angleDiff = headingDifference.wrap(min: -180, max: 180)
        
        if angleDiff > 45 && angleDiff < 135 {
            return "Turn right"
        } else if angleDiff >= 135 || angleDiff <= -135 {
            return "Make a U-turn"
        } else if angleDiff < -45 && angleDiff > -135 {
            return "Turn left"
        } else if angleDiff >= -45 && angleDiff <= 45 {
            return "Continue straight"
        } else {
            return "Proceed"
        }
    }
}

// Extension to help with direction calculations
extension CLLocationDirection {
    func wrap(min: CLLocationDirection, max: CLLocationDirection) -> CLLocationDirection {
        let range = max - min
        let normalized = self - min
        let wrapped = normalized.truncatingRemainder(dividingBy: range)
        return wrapped >= 0 ? wrapped + min : wrapped + max
    }
    
    func difference(from other: CLLocationDirection) -> CLLocationDirection {
        let diff = (self - other).wrap(min: -180, max: 180)
        return diff
    }
}

extension CLLocationCoordinate2D {
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = self.latitude * .pi / 180
        let lon1 = self.longitude * .pi / 180
        let lat2 = coordinate.latitude * .pi / 180
        let lon2 = coordinate.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearingRadians = atan2(y, x)
        
        var bearingDegrees = bearingRadians * 180 / .pi
        if bearingDegrees < 0 {
            bearingDegrees += 360
        }
        
        return bearingDegrees
    }
}
