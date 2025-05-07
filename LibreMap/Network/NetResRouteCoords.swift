//
//  NetResRouteCoords.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation

public protocol NetResBody: Codable {
    
}

struct NetResRoute: NetResBody {
    var map: NetResRouteCoords?
    var tariff: [NetResTaxiTariff]
}

struct NetResRouteCoords: Codable {
    var routings: [NetResRouteCoordsItem]
    let distance, duration: Double
    
    enum CodingKeys: String, CodingKey {
        case routings = "routing"
        case distance
        case duration
    }
}

struct NetResRouteCoordsItem: Codable {
    let longitude, latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case longitude = "lng"
        case latitude = "lat"
    }
}
