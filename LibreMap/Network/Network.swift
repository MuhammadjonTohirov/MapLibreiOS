//
//  Network.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation

struct Logging {
    public static func l(tag: @autoclosure () -> String = "Log", _ message: @autoclosure () -> Any) {
        #if DEBUG
        print("\(tag()): \(message())")
        #endif
    }
}

import Foundation

public protocol NetworkDelegate {
    func onAuthRequired()
    func onFailureNetwork()
}

public func setNetworkDelegate(_ delegate: NetworkDelegate?) {
    Network.delegate = delegate
}

public struct Network {

    nonisolated(unsafe) public static var delegate: NetworkDelegate?
    
    public static func send<T: NetResBody>(urlSession: URLSession = URLSession.shared, request: URLRequestProtocol) async -> NetRes<T>? {
        do {
            return try await sendThrow(request: request)
        } catch let error {
            Logging.l(error)
            return nil
        }
    }
    
    public static func sendThrow<T: NetResBody>(urlSession: URLSession = URLSession.shared, request: URLRequestProtocol) async throws -> NetRes<T>? {
        do {
            Logging.l("--- --- REQUEST --- ---")
            Logging.l(request.url.absoluteString)
            
            if let requestBody = request.request().httpBody,
               let json = try JSONSerialization.jsonObject(with: requestBody, options: .fragmentsAllowed) as? [String: Any],
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]) {
                Logging.l(String.init(data: jsonData, encoding: .utf8) ?? "")
            }
            
            var result: (Data, URLResponse?)!
            
            do {
                result = try await urlSession.data(for: request.request())
            } catch {
                throw NetworkError.timeout
            }
            
            let data = result.0

            let code = (result.1 as! HTTPURLResponse).statusCode

            guard await onReceive(code: code) else {
                throw NetworkError.unauthorized
            }
            
            let str = try data.asJsonString()
            
            Logging.l("--- --- RESPONSE --- ---")
            Logging.l((request.url, code))
            Logging.l(str ?? "")
            
            let res = try JSONDecoder().decode(NetRes<T>.self, from: data)
            
            Logging.l("Parsing is successful")
            
            guard await onReceive(code: res.code ?? code) else {
                throw NetworkError.unauthorized
            }
            
            if !res.success {
                throw NetworkError.custom(message: res.message ?? "Unknown error")
            }
            
            return res
        } catch let error {
            debugPrint(error)
            throw NetworkError.custom(message: error.serverMessage, code: -1)
        }
    }
    
    private static func onReceive(code: Int) async -> Bool {
        if code == 401 {
            delegate?.onAuthRequired()
            return false
        }
        
        return true
    }
    
    private static func onFail(forUrl url: String) {
        Logging.l("--- --- RESPONSE --- ---")
        Logging.l("nil data received from \(url)")
    }
    
    public static func upload<T: NetResBody>(body: T.Type, request: URLRequestProtocol, completion: @escaping (NetRes<T>?) -> Void) {
        Logging.l("--- --- REQUEST --- ---")
        Logging.l(request.url.absoluteString)
        
        if let requestBody = request.request().httpBody,
           let json = try? JSONSerialization.jsonObject(with: requestBody, options: .fragmentsAllowed) as? [String: Any]
        {
            Logging.l(json)
        }
        
        URLSession.shared.uploadTask(with: request.request(), from: request.body) { data, a, error in
            guard let data = data, let res = try? JSONDecoder().decode(NetRes<T>.self, from: data) else {
                Logging.l(error?.localizedDescription ?? "Unable to parse data")
                completion(nil)
                return
            }

            
            Logging.l("--- --- RESPONSE --- ---")

            completion(res)
        }.resume()
    }
    
    public static func upload<T: NetResBody>(body: T.Type, request: URLRequestProtocol) async throws -> NetRes<T> {
        Logging.l("--- --- REQUEST --- ---")
        Logging.l(request.url.absoluteString)
        
        // Ensure the request doesn't contain a body
        var mutableRequest = request.request()
        mutableRequest.httpBody = nil // Clear the body

        // Log the JSON body (optional)
        if let requestBody = request.body,
           let json = try? JSONSerialization.jsonObject(with: requestBody, options: .fragmentsAllowed) as? [String: Any] {
            Logging.l(json)
        }

        guard let data = request.body else {
            fatalError("No data on request")
        }

        // Perform the upload with the provided data
        let (resultData, _) = try await URLSession.shared.upload(for: mutableRequest, from: data)
        
        // Log the response (optional)
        if let json = try? JSONSerialization.jsonObject(with: resultData, options: .fragmentsAllowed) as? [String: Any] {
            Logging.l(json)
        }

        // Decode the response
        guard let res = try? JSONDecoder().decode(NetRes<T>.self, from: resultData) else {
            fatalError("Unable to parse data")
        }

        return res
    }

}

public extension Data {
    func asJson() throws -> Any {
        let json = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        
        return json
    }
    
    func asJsonString() throws -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: asJson(), options: [.prettyPrinted, .sortedKeys])
        return String.init(data: self, encoding: .utf8)
    }
}
