//
//  MapControlsView.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//
// MapControlsView.swift

import SwiftUI

struct MapControlsView: View {
    @ObservedObject var viewModel: MapLibreWrapperModel
    var onUserLocationTap: () -> Void
    var onZoomInTap: () -> Void
    var onZoomOutTap: () -> Void
    var onCompassTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // User location button
            Button(action: onUserLocationTap) {
                Image(systemName: "location.fill")
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            
            // Zoom in button
            Button(action: onZoomInTap) {
                Image(systemName: "plus")
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            
            // Zoom out button
            Button(action: onZoomOutTap) {
                Image(systemName: "minus")
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            
            // Compass button
            Button(action: onCompassTap) {
                Image(systemName: "compass")
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
        }
        .padding()
    }
}
