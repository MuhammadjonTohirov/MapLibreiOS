//
//  NetResTaxiTariff.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation

// MARK: - TaxiTariffs
struct NetResTaxiTariffList: NetResBody {
    let tariffs: [NetResTaxiTariff]
    
    enum CodingKeys: String, CodingKey {
        case tariffs = "tariff"
    }
}

// MARK: - Tariff
struct NetResTaxiTariff: Codable {
    let id: Int
    let name: String?
    let description: String?
    let photo, icon: String?
    let cost, cityKMCost: Float?
    let includedKM: Double?
    let fixedType: Bool?
    let fixedPrice: Float?
    let secondAddress: Bool?
    let index: Int?
    var services: [NetResTaxiTariffService]?
    var category: NetResTaxiTariffCategory?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, photo, icon, cost
        case cityKMCost = "city_km_cost"
        case includedKM = "included_km"
        case fixedType = "fixed_type"
        case fixedPrice = "fixed_price"
        case secondAddress = "second_address"
        case index, services
    }
}

struct NetResTaxiTariffCategory: Codable {
    let id: Int
    let name: String
}

// MARK: - Service
struct NetResTaxiTariffService: Codable, Identifiable {
    var id: Int
    let cost: Int
    let name, costType: String

    enum CodingKeys: String, CodingKey {
        case cost, name
        case id
        case costType = "cost_type"
    }
    
    var isSelected: Bool = false
}
