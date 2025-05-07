//
//  MapCamera.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import MapLibre

public struct MapCamera {
    public var camera: MLNMapCamera
    public var animate: Bool
    
    public init(camera: MLNMapCamera, animate: Bool) {
        self.camera = camera
        self.animate = animate
    }
}
