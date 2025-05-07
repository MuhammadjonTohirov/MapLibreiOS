//
//  MapRouteDisplayModel.swift
//  LibreMap
//
//  Created for MapLibre integration
//

import Foundation
import MapLibre
import CoreLocation

/// Model for storing and managing route display data
public struct MapRoute: Identifiable {
    public let id: String
    public let title: String?
    public let coordinates: [CLLocationCoordinate2D]
    public let color: UIColor
    public let width: CGFloat
    
    public init(
        id: String = UUID().uuidString,
        title: String? = nil,
        coordinates: [CLLocationCoordinate2D],
        color: UIColor = .blue,
        width: CGFloat = 4.0
    ) {
        self.id = id
        self.title = title
        self.coordinates = coordinates
        self.color = color
        self.width = width
    }
}
