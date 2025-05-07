//
//  OfflineMapManager.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//
// OfflineMapManager.swift

import Foundation
import MapLibre

class OfflineMapManager {
    static let shared = OfflineMapManager()
    
    private var offlinePacks: [MLNOfflinePack]?
    private var mapView: MLNMapView?
    
    private init() {}
    
    func setup(with mapView: MLNMapView) {
        self.mapView = mapView
        refreshOfflinePacks()
    }
    
    // MARK: - Offline Pack Management
    
    func refreshOfflinePacks() {
        offlinePacks = MLNOfflineStorage.shared.packs
    }
    
    func downloadOfflineMap(forRegion region: MLNCoordinateBounds,
                            fromZoomLevel minimumZoomLevel: Double = 10,
                            toZoomLevel maximumZoomLevel: Double = 15,
                            withName name: String) {
        
        guard let mapView = mapView, let styleURL = mapView.styleURL else { return }
        
        refreshOfflinePacks()
        
        // Check if we already have a pack with this name
        if let existingPack = offlinePacks?.first(where: { $0.description == name }) {
            MLNOfflineStorage.shared.removePack(existingPack) { error in
                if let error = error {
                    print("Error removing existing offline pack: \(error.localizedDescription)")
                }
            }
        }
        
        // Create the offline region
        let regionDefinition = MLNTilePyramidOfflineRegion(styleURL: styleURL,
                                                          bounds: region,
                                                          fromZoomLevel: minimumZoomLevel,
                                                          toZoomLevel: maximumZoomLevel)
        
        // Create JSON metadata
        let metadata = ["name": name]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: metadata, options: []) else {
            print("Failed to create JSON metadata for offline pack")
            return
        }
        
        // Create the offline pack
        MLNOfflineStorage.shared.addPack(for: regionDefinition, withContext: jsonData) { pack, error in
            if let error = error {
                print("Error creating offline pack: \(error.localizedDescription)")
                return
            }
            
            guard let pack = pack else {
                print("Failed to create offline pack")
                return
            }
            
            // Start the download
            pack.resume()
        }
    }
    
    func getOfflinePacks() -> [MLNOfflinePack] {
        refreshOfflinePacks()
        return offlinePacks ?? []
    }
    
    func removeOfflinePack(withName name: String, completion: @escaping (Error?) -> Void) {
        refreshOfflinePacks()
        
        if let packToRemove = offlinePacks?.first(where: { $0.description == name }) {
            MLNOfflineStorage.shared.removePack(packToRemove, withCompletionHandler: completion)
        } else {
            completion(nil) // No pack found with that name
        }
    }
}
