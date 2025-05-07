//
//  PolylineControlsView.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import SwiftUI
import CoreLocation

public struct PolylineControlsView: View {
    @ObservedObject var viewModel: MapLibreWrapperModel
    @State private var polylineTitle: String = ""
    @State private var showingTitleInput = false
    @State private var selectedColor: Color = .blue
    @State private var lineWidth: Double = 3.0
    @State private var showingOptions = false
    
    public var body: some View {
        VStack {
            if viewModel.isDrawingPolyline {
                // Drawing mode controls
                VStack(spacing: 8) {
                    HStack {
                        Text("Drawing Polyline")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showingOptions = true
                        }) {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            showingTitleInput = true
                        }) {
                            Text("Finish")
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            viewModel.cancelPolylineDrawing()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(16)
                        }
                    }
                    
                    if showingOptions {
                        VStack {
                            HStack {
                                Text("Color:")
                                    .foregroundColor(.white)
                                
                                ForEach([Color.blue, Color.red, Color.green, Color.orange, Color.purple], id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                            
                            HStack {
                                Text("Width: \(Int(lineWidth))")
                                    .foregroundColor(.white)
                                
                                Slider(value: $lineWidth, in: 1...10, step: 1)
                                    .frame(width: 120)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Point counter and instructions
                    Text("\(viewModel.drawingCoordinates.count) points - Tap map to add points")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(16)
                .shadow(radius: 5)
            } else {
                // Start drawing button
                Button(action: {
                    viewModel.startPolylineDrawing()
                }) {
                    HStack {
                        Image(systemName: "pencil.line")
                        Text("Draw Polyline")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .shadow(radius: 3)
                }
            }
        }
        .padding()
        .alert("Name Your Polyline", isPresented: $showingTitleInput) {
            TextField("Optional Title", text: $polylineTitle)
            
            Button("Cancel", role: .cancel) {
                polylineTitle = ""
            }
            
            Button("Save") {
                // Convert SwiftUI Color to UIColor
                let uiColor = UIColor(selectedColor)
                
                viewModel.finishPolylineDrawing(
                    title: polylineTitle.isEmpty ? nil : polylineTitle,
                    color: uiColor,
                    width: CGFloat(lineWidth)
                )
                polylineTitle = ""
                showingOptions = false
            }
        } message: {
            Text("Enter a name for your polyline or leave blank")
        }
    }
}

// Helper extension to convert SwiftUI Color to UIColor
extension UIColor {
    convenience init(_ color: Color) {
        let components = color.components()
        self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }
}

extension Color {
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        
        // Default color values for known colors
        if self == .red { return (1.0, 0.0, 0.0, 1.0) }
        if self == .green { return (0.0, 1.0, 0.0, 1.0) }
        if self == .blue { return (0.0, 0.0, 1.0, 1.0) }
        if self == .orange { return (1.0, 0.5, 0.0, 1.0) }
        if self == .purple { return (0.5, 0.0, 0.5, 1.0) }
        
        // If the color is described in hex or other formats
        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        
        return (r, g, b, a)
    }
}

// MARK: - Usage Example
/// Example of how to use the polyline drawing in your ContentView
public struct MapPolylineExample: View {
    @StateObject private var viewModel = MapLibreWrapperModel()
    
    public var body: some View {
        ZStack {
            // Map view
            MLNMapViewWrapper(
                viewModel: viewModel,
                styleUrl: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
                inset: .init(
                    insets: .init(top: 0, left: 0, bottom: 100, right: 0),
                    animated: false
                ),
                trackingMode: .followWithHeading
            )
            .ignoresSafeArea()
            
            VStack {
                // Polyline drawing controls at the top
                PolylineControlsView(viewModel: viewModel)
                
                Spacer()
                
                // Bottom area for displaying saved polylines
                if !viewModel.savedPolylines.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.savedPolylines) { polyline in
                                VStack {
                                    Text(polyline.title ?? "Untitled")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        viewModel.removePolyline(id: polyline.id)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                            }
                            
                            if viewModel.savedPolylines.count > 1 {
                                Button(action: {
                                    viewModel.clearAllPolylines()
                                }) {
                                    Text("Clear All")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.black.opacity(0.5))
                }
            }
        }
        .onAppear {
            // Example: Add a sample polyline when view appears
            let exampleCoords = [
                CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298),
                CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298 + 0.01),
                CLLocationCoordinate2D(latitude: 41.8781 + 0.005, longitude: -87.6298 + 0.015),
                CLLocationCoordinate2D(latitude: 41.8781 + 0.01, longitude: -87.6298 + 0.01)
            ]
            
            viewModel.addPolyline(
                coordinates: exampleCoords,
                title: "Example Route",
                color: UIColor.purple,
                width: 5.0
            )
        }
    }
}

