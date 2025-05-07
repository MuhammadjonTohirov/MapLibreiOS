//
//  RouteTariffCalcGateway.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation

protocol RouteTariffCalcGatewayProtocol {
    func calculateRouteAndTariffs(
        req: NetReqTaxiTariff
    ) async throws -> (
        map: NetResRouteCoords?,
        tariffs: [NetResTaxiTariff]?
    )
}

final class RouteTariffCalcGateway: RouteTariffCalcGatewayProtocol {
    private lazy var session: URLSession = URLSession(configuration: .default)
    
    func calculateRouteAndTariffs(
        req: NetReqTaxiTariff
    ) async throws -> (map: NetResRouteCoords?, tariffs: [NetResTaxiTariff]?) {
        await session.tasks.0.forEach({$0.cancel()})
        let result: NetRes<NetResRoute>? = try await Network.sendThrow(
            urlSession: session,
            request: Request(input: req)
        )
        
        return (map: result?.result?.map, tariffs: result?.result?.tariff)
    }
    
    struct Request: URLRequestProtocol {
        let input: NetReqTaxiTariff
        
        var url: URL = .init(string: "https://api2.ildam.uz/client/address/tariff/cost")!
        
        var body: Data? {
            try? JSONEncoder().encode(input)
        }
        
        var method: HTTPMethod = .post
        
        func request() -> URLRequest {
            var req = URLRequest(url: url)
            req.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI1IiwianRpIjoiZGMzY2UxZmRjNGYwYmI2MTc4NmFiMTIxMDY4YzA2OThhZWM1MzI4NzkwN2VhN2U3ODVhNzgxYTIyM2MyNDQ1YjlhN2U4OGY3YTI4MzUwMGQiLCJpYXQiOjE3NDMxNTQyNzUuMzIyNjk1LCJuYmYiOjE3NDMxNTQyNzUuMzIyNjk2LCJleHAiOjE3NzQ2OTAyNzUuMzE2NDY1LCJzdWIiOiIyNDIwMzUiLCJzY29wZXMiOlsiY2xpZW50Il19.yMYcmox4VN4bod0DqtEoP2n1gzOIMaZWUQjffb0YJHss_ob5eY2BATpyy5c6An2ohJ65LTa0BOPFaaUedCffu0KIhdM3f_srm58utWsYGvfNLAwryuVxOIe5rBLm_NVU9BrCZqvUZN-uWDcTx8JX8ElkWAvfTYMk6P5hT_aPgL8yDl4OwfkFU5FRXwvs93jXVrx7ChcjCR_e4aLZjnnzXHLWuY0ov5GHB9COy2ndbyKvpfG_SxFmlnwDz6bn21IkI2oUKcaktMEhStGSEH3NVZaq_nOgwH55KTqIEE8UOmgKmhuJGgkphTcZYw6iaG8AwY9LxyErX3ANtBazQ9gU_KEUwLCQZc92VlI8z_KrvSkMKxB_U-Hk6mDXPZeDZBokV0F5mruCX8gZ5vaNMoTFPzlgQi6SIquh01wngweU9d8_ExWdiZEihvz0qBl5H47ULQXx30i6tWTSi9iW5MvrHcH8HkCz8QZ3k2mbAOKdrxokeXG0uEk_oD00V_yH0KxFLGutdDOFtXCFBfKUQJEBLpP-Hay9FJfJzIyIsdBR8hFiy2nhUSkp16ME0tNhTWmMqd6Ys2kALzrmDzTQVYePMG_sq8oBPSTtSATjIChxAZoFaVKsB_3ifS8fPaIthwSFQ3Pw-TIb-aTTpqLiibSf2O3BcuUpcJbZv_WbOQN6P6Q",
                "secret-key": "2f52434c-3068-460d-8dbc-5c80599f2db4",
                "brand-id": "2",
                "lang": "uz",
                "User-Agent-OS": "ios"
            ]
            return req
        }
    }
}
