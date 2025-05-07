//
//  ContentView.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 06/05/25.
//

import SwiftUI

//"https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",

struct ContentView: View {
    @StateObject var viewModel: MapLibreWrapperModel = .init()
    var body: some View {
        MLNMapViewWrapper(
            viewModel: viewModel,
            styleUrl: "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
            inset: .init(
                insets: .init(top: 0, left: 0, bottom: 100, right: 0),
                animated: false,
                onEnd: {
                    
                }
            ),
            trackingMode: .followWithHeading
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

