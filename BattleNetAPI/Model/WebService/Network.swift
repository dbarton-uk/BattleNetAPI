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


class Network {
    static let shared = Network()
    private init() { }
    
    /// The access token for game data services
    public var clientAccessToken: String?
    /// The access token for profile services
    public var userAccessToken: String?
    /// The encrypted client credentials for a Basic request, used to retrieve the client access token
    public var encryptedCredentials: String?
    
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
        
        if apiType == .profile || apiType == .community,
            let userAccessToken = userAccessToken {
            request.setValue(String(format: "Bearer %@", userAccessToken), forHTTPHeaderField: "Authorization")
        }
        else if apiType == .gameData,
            let clientAccessToken = clientAccessToken {
            request.setValue(String(format: "Bearer %@", clientAccessToken), forHTTPHeaderField: "Authorization")
        }
        else if let encryptedCredentials = encryptedCredentials {
            request.setValue(String(format: "Basic %@", encryptedCredentials), forHTTPHeaderField: "Authorization")
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
                    completion(.success(data))
                }
                else if let httpError = HTTPError(statusCode: statusCode) {
                    completion(.failure(httpError))
                }
                else {
                    completion(.failure(HTTPError(type: .httpError)))
                }
            }
            else if let error = error as NSError? {
                completion(.failure(HTTPError(from: error)))
            }
            else {
                completion(.failure(HTTPError(type: .httpError)))
            }
        }.resume()
    }
}
