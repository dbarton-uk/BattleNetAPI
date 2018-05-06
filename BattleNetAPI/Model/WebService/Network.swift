//
//  Network.swift
//  BattleNetAPI
//
//  Created by Christopher Jennewein on 4/6/18.
//  Copyright © 2018 Prismatic Games. All rights reserved.
//

import Foundation


enum HTTPMethod: String {
    case get, post, put, delete, patch, head
}


enum Result<T> {
    case success(T)
    case failure(HTTPError)
}


extension Result {
    init(value: T?, error: HTTPError?) {
        switch (value, error) {
        case (let v?, _):
            self = .success(v)
        case (nil, let e?):
            self = .failure(e)
        case (nil, nil):
            let error = HTTPError(type: .httpError, code: 1, description: "Invalid input: value and error were both nil.")
            self = .failure(error)
        }
    }
}


extension Result where T == Data {
    /**
     Decode a successful Result to a class specified in your completion. Will return an HTTPError.jsonParsingError if decoding fails, or the original error is the Result is a failure.
     
     - parameter customDecode: Implement a customDecode method to return the desired Decodable object if it's nested in the data or needs to be configured
     - parameter completion: Called when decoding is complete, or when errors are encountered
    */
    func decode<U: Decodable>(customDecode: ((_ data: Data) throws -> U)? = nil, completion: @escaping (_ result: Result<U>) -> Void) {
        switch self {
        case .success(let data):
            do {
                let decoded = try customDecode?(data) ?? U.decode(from: data)
                completion(Result<U>(value: decoded, error: nil))
            }
            catch {
                completion(Result<U>(value: nil, error: HTTPError(type: .jsonParsingError)))
            }
        case .failure(let error):
            completion(Result<U>(value: nil, error: error))
        }
    }
}



class Network {
    static let shared = Network()
    private init() { }
    
    /// The access token for game data services
    public var clientAccessToken: String? = nil
    /// The access token for profile services
    public var userAccessToken: String? = nil
    
    /// Required for legacy services
    public var apikey: String? = nil
    
    
    
    /**
     Creates a URLRequest sending and receiving JSON by default.
     
     - parameter url: The RESTful URL
     - parameter method: A RESTful HTTP request method
     - parameter apiType: The type of information being accessed which determines which access token is required for authorization
     - returns: The URLRequest or nil if the user has not been authenticated.
     - requires: An accessToken must be saved in the Network class in order to create the URLRequest.
     */
    func createRequest(with url: URL, method: HTTPMethod, apiType: APIType?) -> URLRequest? {
        var request = URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if apiType == .profile,
            let userAccessToken = userAccessToken {
            request.setValue(String.init(format: "Bearer %@", userAccessToken), forHTTPHeaderField: "Authorization")
        }
        else if apiType == .data,
            let clientAccessToken = clientAccessToken {
            request.setValue(String.init(format: "Bearer %@", clientAccessToken), forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    
    /**
     Creates a URLRequest sending and receiving JSON by default.
     
     - parameter url: The RESTful URL
     - parameter method: A RESTful HTTP request method
     - returns: The URLRequest or nil if the user has not been authenticated.
     - requires: An accessToken must be saved in the Network class in order to create the URLRequest.
     */
    func createRequestLegacy(with url: URL, method: HTTPMethod) -> URLRequest? {
        guard let apikey = apikey else {
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems?.append(URLQueryItem(name: "apikey", value: apikey))
        var request = URLRequest(url: urlComponents.url!)
        
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    
    /**
     Starts the URLRequest and returns the response from the server or an error.
     
     - parameter request: The URLRequest
     - parameter completion: Returns the web service response and error
     */
    func start(_ request: URLRequest, completion: @escaping (_ result: Result<Data>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
                let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                
                if (statusCode >= 200 && statusCode < 300) {
                    completion(Result(value: data, error: nil))
                }
                else if statusCode == 401 {
                    completion(Result(value: nil, error: HTTPError(type: .unauthorized)))
                }
                else if statusCode == 403 {
                    completion(Result(value: nil, error: HTTPError(type: .forbidden)))
                }
                else {
                    completion(Result(value: nil, error: HTTPError(type: .httpError)))
                }
            }
            else if let error = error as NSError? {
                completion(Result(value: nil, error: HTTPError(from: error)))
            }
            else {
                completion(Result(value: nil, error: HTTPError(type: .httpError)))
            }
        }.resume()
    }
}