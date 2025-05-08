//
//  CarMarkerView.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import SwiftUI
import MapLibre

struct CarMarkerView: View {
    var position: CLLocationCoordinate2D
    var heading: Double
    
    var body: some View {
        Image(systemName: "car.fill")
            .font(.system(size: 24))
            .foregroundColor(.blue)
            .background(
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
            )
            .rotationEffect(Angle(degrees: heading))
    }
}


struct NavigationOverlayView: View {
    @ObservedObject var navigationService: NavigationService
    var onEndNavigation: () -> Void
    
    var body: some View {
        VStack {
            // Top navigation instructions
            VStack {
                Text(navigationService.currentInstruction)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                Text(navigationService.upcomingManeuver)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
            
            // Bottom information panel
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Distance Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDistance(navigationService.remainingDistance))
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("ETA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatTime(navigationService.estimatedTimeRemaining))
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                
                Button(action: onEndNavigation) {
                    Text("End Navigation")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
            .padding()
        }
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        } else {
            return "\(Int(distance)) m"
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: timeInterval) ?? "Unknown"
    }
}
