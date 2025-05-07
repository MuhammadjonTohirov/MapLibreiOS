//
//  MapLibreWrapper.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 06/05/25.
//

import Foundation
import MapLibre
import SwiftUI

public struct MLNMapViewWrapper: UIViewRepresentable {
    var viewModel: MapLibreWrapperModel?
    var camera: MapCamera?
    var styleUrl: String? = "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
    var inset: MapEdgeInsets?
    var trackingMode: MLNUserTrackingMode?
    
    public init(
        viewModel: MapLibreWrapperModel? = nil,
        camera: MapCamera? = nil,
        styleUrl: String? = nil,
        inset: MapEdgeInsets? = nil,
        trackingMode: MLNUserTrackingMode? = nil
    ) {
        self.viewModel = viewModel
        self.camera = camera
        self.styleUrl = styleUrl
        self.inset = inset
        self.trackingMode = trackingMode
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public typealias UIViewType = MLNMapView
    
    public func makeUIView(context: Context) -> MLNMapView {

        let styleURL = URL(string: styleUrl ?? "")
        
        let view = MLNMapView(frame: .zero, styleURL: styleURL)
        view.showsUserLocation = true
        view.zoomLevel = 15
        view.showsUserHeadingIndicator = true
        view.delegate = viewModel
        view.prefetchesTiles = true
        view.tileCacheEnabled = true
        viewModel?.mapView = view
        return view
    }
    
    public func updateUIView(_ uiView: MLNMapView, context: Context) {
        if let camera {
            uiView.setCamera(camera.camera, animated: camera.animate)
        }
        
        if let inset {
            uiView.setContentInset(inset.insets, animated: true, completionHandler: inset.onEnd)
        }
        
        if let trackingMode {
            uiView.userTrackingMode = trackingMode
        }
        guard let viewModel else { return }
        
        uiView.removeOverlays(uiView.overlays)
        uiView.addOverlays(viewModel.polylines)
        uiView.addOverlays(viewModel.polygons)
    }
    
    public final class Coordinator: NSObject, ObservableObject {
        public var parent: MLNMapViewWrapper
        
        public init(parent: MLNMapViewWrapper) {
            self.parent = parent
        }
    }
}
