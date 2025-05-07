//
//  MapStyle.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//
// MapStyle.swift

import Foundation

enum MapStyle: String, CaseIterable {
    case voyager = "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json"
    case darkMatter = "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json"
    case positron = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"
    
    var displayName: String {
        switch self {
        case .voyager:
            return "Voyager"
        case .darkMatter:
            return "Dark Matter"
        case .positron:
            return "Positron"
        }
    }
}
