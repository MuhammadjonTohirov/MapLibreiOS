//
//  MapPolyline.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import UIKit.UIColor
import CoreLocation

// MARK: - MapPolyline Model
/// Model representing a polyline on the map
public struct MapPolyline: Identifiable {
    public let id: String
    public let title: String?
    public let coordinates: [CLLocationCoordinate2D]
    public let color: UIColor
    public let width: CGFloat
    
    public init(id: String = UUID().uuidString,
                title: String? = nil,
                coordinates: [CLLocationCoordinate2D],
                color: UIColor = .blue,
                width: CGFloat = 3.0) {
        self.id = id
        self.title = title
        self.coordinates = coordinates
        self.color = color
        self.width = width
    }
}
