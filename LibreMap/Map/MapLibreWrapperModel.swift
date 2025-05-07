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
    
    @Published public var polylines: [MLNPolyline] = []
    @Published public var polygons: [MLNPolygon] = []

    public func addPolyline(coordinates: [CLLocationCoordinate2D], title: String? = nil) {
        let polyline = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        polyline.title = title
        polylines.append(polyline)
    }

    public func addPolygon(coordinates: [CLLocationCoordinate2D], title: String? = nil) {
        let polygon = MLNPolygon(coordinates: coordinates, count: UInt(coordinates.count))
        polygon.title = title
        polygons.append(polygon)
    }
    
    public func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        debugPrint("Did finish loading map style")
    }
    
    public func mapView(_ mapView: MLNMapView, didChange mode: MLNUserTrackingMode, animated: Bool) {
        debugPrint("Did change user tracking mode to \(mode) animated: \(animated)")
    }
}
