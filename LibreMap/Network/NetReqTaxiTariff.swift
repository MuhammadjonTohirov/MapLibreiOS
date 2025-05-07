//
//  NetResTaxiTariff.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation

struct NetReqTaxiTariff: Codable {
    let coords: [NetCoord]
    var optionIDS: [Int]
    var tariffID: Int?
    var addressId: Int?
    
    enum CodingKeys: String, CodingKey {
        case coords
        case optionIDS = "option_ids"
        case tariffID = "tariff_id"
        case addressId = "address_id"
    }
    
    init(coords: [NetCoord], options: [Int] = [], tariff: Int? = nil, address: Int?) {
        self.coords = coords
        self.optionIDS = options
        self.tariffID = tariff
        self.addressId = address
    }
    
    init(lat: Double, lng: Double, options: [Int], addressId: Int = 0) {
        self.init(coords: [NetCoord(lat: lat, lng: lng)], options: options, address: addressId)
    }
    
    init(coords: [(lat: Double, lng: Double)], options: [Int], addressId: Int = 0) {
        self.init(coords: coords.map { NetCoord.init(lat: $0.lat, lng: $0.lng) }, options: options, address: addressId)
    }
}

// MARK: - Coord
struct NetCoord: Codable {
    let lat, lng: Double
}
