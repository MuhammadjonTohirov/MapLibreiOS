//
//  MapLibreWrapperModel.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import MapLibre

open class MapLibreWrapperModel: NSObject, ObservableObject, MLNMapViewDelegate {
    weak var mapView: MLNMapView?
    
    // Published properties to track polyline drawing state
    @Published public var isDrawingPolyline: Bool = false
    @Published public var drawingCoordinates: [CLLocationCoordinate2D] = []
    @Published public var savedPolylines: [MapPolyline] = []
    
    // Temporary source and layer IDs for drawing
    let tempPolylineSourceID = "temp-polyline-source"
    let tempPolylineLayerID = "temp-polyline-layer"
}
