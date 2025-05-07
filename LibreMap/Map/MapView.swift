//
//  MapView.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation
import SwiftUI
import MapLibre

struct MapView: View {
    @StateObject private var viewModel: MapLibreWrapperModel = .init()
    @State private var selectedStyle: MapStyle = .voyager
    
    var body: some View {
        ZStack {
            MLNMapViewWrapper(
                viewModel: viewModel,
                styleUrl: selectedStyle.rawValue,
                inset: .init(
                    insets: .init(top: 0, left: 0, bottom: 100, right: 0),
                    animated: false
                ),
                trackingMode: .followWithHeading
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Map style selector
                HStack {
                    Spacer()
                    
                    Menu {
                        Picker("Map Style", selection: $selectedStyle) {
                            ForEach(MapStyle.allCases, id: \.self) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                    } label: {
                        Image(systemName: "map")
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MapView()
}
