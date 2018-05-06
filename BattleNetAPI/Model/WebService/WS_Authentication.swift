//
//  Authentication.swift
//  BattleNetAPI
//
//  Created by Christopher Jennewein on 4/6/18.
//  Copyright © 2018 Prismatic Games. All rights reserved.
//

import Foundation


class WS_Authentication: WebService {
    private let network = Network.shared
    
    
    
    func getBaseURL(region: APIRegion, apiType: APIType?) -> String {
        return region.authorizeURI
    }
    
    
    /**
     Returns the access dictionary configured for the your application
     
     - parameter region: The user's current region
     - parameter clientID: The clientID of your application, provided by Blizzard
     - parameter clientSecret: The clientSecret of your application, provided by Blizzard
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     - note: This access token will not return specific user information. If that is needed, you must receive a user access token through OAuth
     */
    func getClientAccessToken(region: APIRegion, clientID: String, clientSecret: String, completion: @escaping (_ result: Result<Data>) -> Void) {
        // TODO: validate clientID and clientSecret
        
        let urlStr = String(format: "\(region.tokenURI)?grant_type=client_credentials&client_id=%@&client_secret=%@", clientID, clientSecret)
        self.callWebService(urlStr: urlStr, method: .get, apiType: nil) { result in
            // extract and save clientAccessToken to Network for future calls
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                        Network.shared.clientAccessToken = json["access_token"] as? String
                        completion(result)
                    }
                    else {
                        completion(Result(value: nil, error: HTTPError(type: .unexpectedResponse)))
                    }
                }
                catch {
                    completion(Result(value: nil, error: HTTPError(type: .jsonParsingError)))
                }
            case .failure(_):
                completion(result)
            }
        }
    }
    
    
    /**
     Returns the access dictionary configured for the user that logged in through OAuth
     
     - parameter region: The user's current region
     - parameter clientID: The clientID of your application, provided by Blizzard
     - parameter clientSecret: The clientSecret of your application, provided by Blizzard
     - parameter code: The code returned to the app when the user logs in through OAuth
     - parameter redirectURL: The url provided to the OAuth
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getUserAccessToken(region: APIRegion, clientID: String, clientSecret: String, code: String, redirectURL: String, completion: @escaping (_ result: Result<Data>) -> Void) {
        let urlStr = region.tokenURI
        
        let parameters = String(format: "grant_type=authorization_code&client_id=%@&client_secret=%@&code=%@&redirect_uri=%@", clientID, clientSecret, code, redirectURL)
        let body = parameters.data(using: .utf8)
        
        self.callWebService(urlStr: urlStr, method: .post, apiType: nil, body: body, headers: [.contentType([.form])]) { result in
            // extract and save userAccessToken to Network for future calls
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
                        Network.shared.userAccessToken = json["access_token"] as? String
                        completion(result)
                    }
                    else {
                        completion(Result(value: nil, error: HTTPError(type: .unexpectedResponse)))
                    }
                }
                catch {
                    completion(Result(value: nil, error: HTTPError(type: .jsonParsingError)))
                }
            case .failure(_):
                completion(result)
            }
        }
    }
    
    
    /**
     Checks if the client token is valid to be used with web service calls
     
     - parameter token: The client token saved in the app
     - parameter region: What region the request is being made
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func validateClientAccessToken(_ token: String, region: APIRegion, completion: @escaping (_ result: Result<Data>) -> Void) {
        let urlStr = String(format: "\(region.checkTokenURI)?token=%@", token)
        self.callWebService(urlStr: urlStr, method: .post, apiType: nil) { result in
            // extract and save clientAccessToken to Network for future calls
            if case Result.success(_) = result {
                Network.shared.clientAccessToken = token
            }
            
            completion(result)
        }
    }
    
    
    /**
     Checks if the user access token is valid to be used with profile web service calls
     
     - parameter token: The client token saved in the app
     - parameter region: What region the request is being made
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func validateUserAccessToken(_ token: String, region: APIRegion, completion: @escaping (_ result: Result<Data>) -> Void) {
        let urlStr = String(format: "\(region.checkTokenURI)?token=%@", token)
        self.callWebService(urlStr: urlStr, method: .post, apiType: nil) { result in
            // extract and save clientAccessToken to Network for future calls
            if case Result.success(_) = result {
                Network.shared.userAccessToken = token
            }
            
            completion(result)
        }
    }
    
    
    /**
     Constructs the url that can be used to send the user to the OAuth webpage.
     
     - parameter region: The user's current region
     - parameter clientID: The clientID of your application, provided by Blizzard
     - parameter scope: The scope of information you're requesting from the user
     - parameter redirectURL: The redirect url that will be opened after the user has authenticated and will contain the code parameter
     - returns: Example URL: https://us.battle.net/oauth/authorize?client_id=x68y75qh6dpzpsthczrdjv9ck57xapms&scope=wow.profile&state=BattleNetAPI1523122301&redirect_url=https://oauth.click/BattleNetAPI/&response_type=code
     - important: Blizzard does not allow redirects to app scheme urls. You would be required to receive the redirect on a server, then could open your app from there. Your app must be configured with a URLScheme before it can be opened by a url
     - note: For testing purposes, unsecure redirects can use https://oauth.click, and they also provide their redirect config for use on private, secure servers
     */
    func getOAuthURL(region: APIRegion, clientID: String, scope: Scope, redirectURL: String) -> String {
        /// A randomly-generated string used to validate that the auth request made is the same as the auth response (after redirect)
        let state = "BattleNetAPI\(Int(Date().timeIntervalSince1970))"
        UserDefaults.standard.set(state, forKey: "state")
        
        let urlStr = String(format: "\(region.authorizeURI)?client_id=%@&scope=%@&state=%@&redirect_uri=%@&response_type=code", clientID, scope.scopeValue, state, redirectURL)
        
        if let encodedURLStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return encodedURLStr
        }
        else {
            return urlStr
        }
    }
}



class WS_AuthenticationLegacy {
    private let network = Network.shared
    
    func setApikeyLegacy(_ clientID: String) {
        network.apikey = clientID
    }
}