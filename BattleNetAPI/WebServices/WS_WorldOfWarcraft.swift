//
//  WS_WorldOfWarcraft.swift
//  BattleNetAPI
//
//  Created by Christopher Jennewein on 4/8/18.
//  Copyright © 2018 Prismatic Games. All rights reserved.
//

import Foundation


public struct WS_WorldOfWarcraft: WebService {
    public enum API: APICall {
        // Game Data APIs
        case achievement(Int)
        case auctions(String)
        case connectedRealmIndex
        case connectedRealm(Int)
        case item(Int)
        case itemSet(Int)
        case mountIndex
        case mythicKeystoneAffixIndex
        case mythicKeystoneAffix(Int)
        // Profile APIs
        case characters
        case mythicKeystoneProfile(realmSlug: String, characterName: String)
        
        
        var path: String {
            switch self {
            case .achievement(let id):
                return "/achievement/\(id)"
            case .auctions(let realm):
                return "/auction/data/\(realm)"
            case .connectedRealmIndex:
                return "/connected-realm/index"
            case .connectedRealm(let id):
                return "/connected-realm/\(id)"
            case .item(let id):
                return "/item/\(id)"
            case .itemSet(let setID):
                return "/item-set/\(setID)"
            case .mountIndex:
                return "/mount/index"
            case .mythicKeystoneAffixIndex:
                return "/keystone-affix/index"
            case .mythicKeystoneAffix(let id):
                return "/keystone-affix/\(id)"
            case .characters:
                return "/user/characters"
            case .mythicKeystoneProfile(let realmSlug, let characterName):
                return "/character/\(realmSlug)/\(characterName)/mythic-keystone-profile"
            }
        }
        
        var apiType: APIType? {
            switch self {
            case .achievement,
                 .auctions,
                 .connectedRealmIndex, .connectedRealm,
                 .item, .itemSet,
                 .mountIndex,
                 .mythicKeystoneAffixIndex, .mythicKeystoneAffix:
                return .gameData
            case .characters:
                return .community
            case .mythicKeystoneProfile:
                return .profile
            }
        }
        
        
        var basePath: String? {
            switch apiType {
            case .gameData: return "/data/wow"
            case .community: return "/wow"
            case .profile: return "/profile/wow"
            default: return nil
            }
        }
    }
    
    
    var region: APIRegion
    var locale: APILocale?
    
    var session: URLSession
    
    
    var baseURL: URL? { return URL(string: region.apiURI) }
    internal func getBaseURL(apiType: APIType?) -> URL? {
        var url = URL(string: region.apiURI)

        if let apiType = apiType {
            switch apiType {
            case .gameData:
                url?.appendPathComponent("/data/wow")
            case .community:
                url?.appendPathComponent("/wow")
            case .profile:
                url?.appendPathComponent("/profile/wow")
            }
        }

        return url
    }
    
    var authenticationService: AuthenticationWebService?
    
    
    
    /**
     Calls a data web service using a pre-constructed url typically found within another web service result.
     
     - parameter urlStr: The url that will be used to make the web service call
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getResource(from urlStr: String, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        self.callWebService(urlStr: urlStr, method: .get, apiType: .gameData) { result in
            completion(result)
        }
    }
    
    
    /**
     Calls a data web service using a pre-constructed url typically found within another web service result.
     
     - parameter resource: The resource that will be used to make the web service call
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getResource<T>(_ resource: T, completion: @escaping (_ result: Result<Data, Error>) -> Void) where T: ResourceLinkable {
        callWebService(urlStr: resource.link.href, method: .get, apiType: .gameData) { result in
            completion(result)
        }
    }
    
    
    
    
    // MARK: - Game Data API
    
    // MARK: Achievement API
    
    /**
     This provides data about an individual achievement.
     
     - parameter id: The ID of the achievement to retrieve
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    public func getAchievement(id: Int, namespace: APINamespace? = .static, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.achievement(id), namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Auction API
    
    /**
     Auction APIs currently provide rolling batches of data about current auctions. Fetching auction dumps is a two step process that involves checking a per-realm index file to determine if a recent dump has been generated and then fetching the most recently generated dump file if necessary.
     
     This API resource provides a per-realm list of recently generated auction house data dumps.
     
     - parameter realm: The realm being requested
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getAuctions(realm: String, namespace: APINamespace? = .static, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.auctions(realm), namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Connected Realm API
    
    /**
     Get an index of connected-realms
     
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getConnectedRealmIndex(namespace: APINamespace? = .dynamic, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.connectedRealmIndex, namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    /**
     Get a single connected-realm by id
     
     - parameter id: The id of the connected realm
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getConnectedRealm(id: Int, namespace: APINamespace? = .dynamic, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.connectedRealm(id), namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    // MARK: Item API
    
    /**
     The item API provides detailed item information. This includes item set information if this item is part of a set.
     
     - parameter id: Unique ID of the item being requested
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getItem(id: Int, namespace: APINamespace? = .static, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.item(id), namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    /**
     The item API provides detailed item information. This includes item set information if this item is part of a set.
     
     - parameter setID: Unique ID of the set being requested
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getItemSet(setID: Int, namespace: APINamespace? = .static, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.itemSet(setID), namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Mount API
    
    /**
     A list of all supported mounts.
     
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getMounts(namespace: APINamespace? = .static, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.mountIndex, namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Mythic Keystone Affix API
    
    /**
     Returns an index of Keystone affixes.
     
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getMythicKeystoneAffixes(namespace: APINamespace? = .static, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.mythicKeystoneAffixIndex, namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    /**
     The ID of the Keystone affix.
     
     - parameter id: The ID of the Keystone affix
     - parameter namespace: The namespace to use to locate this document.
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getMythicKeystoneAffix(id: Int, namespace: APINamespace? = .static, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.mythicKeystoneAffix(id), namespace: namespace) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Mythic Keystone Dungeon API
    
    /**
     Returns an index of Mythic Keystone dungeons.
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystoneDungeons(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-keystone/dungeon/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns an index of Mythic Keystone dungeons.
     
     - parameter id: The ID of the dungeon
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystoneDungeon(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-keystone/dungeon/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns an index of links to other documents related to Mythic Keystone dungeons.
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystones(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-keystone/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns an index of Mythic Keystone periods.
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystonePeriods(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-keystone/period/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns a Mythic Keystone period by ID.
     
     - parameter id: The ID of the Mythic Keystone season period
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystonePeriod(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-keystone/period/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns an index of Mythic Keystone seasons.
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystoneSeasons(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-keystone/season/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns a Mythic Keystone season by ID.
     
     - parameter id: The ID of the Mythic Keystone season
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystoneSeason(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-keystone/season/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Mythic Keystone Leaderboard API
    
    /**
     Get an index of Mythic Keystone Leaderboard dungeon instances for a connected-realm
     
     - parameter connectedRealmID: The ID of the connected realm
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicLeaderboards(connectedRealmID: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/connected-realm/\(connectedRealmID)/mythic-leaderboard/"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Get a weekly Mythic Keystone Leaderboard by period
     
     - parameter connectedRealmID: The id of the connected realm
     - parameter dungeonID: The id of the dungeon
     - parameter period: The unique identifier for the leaderboard period
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicLeaderboard(connectedRealmID: Int, dungeonID: Int, period: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/connected-realm/\(connectedRealmID)/mythic-leaderboard/\(dungeonID)/period/\(period)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Mythic Raid Leaderboard API
    
    /**
     Returns the leaderboard for a given raid and faction.
     
     - parameter raid: The raid for a leaderboard
     - parameter faction: Player faction ('alliance' or 'horde')
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicRaidLeaderboard(raid: String, faction: FactionType, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/leaderboard/hall-of-fame/\(raid)/\(faction.rawValue.lowercased())"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Mythic Challenge Mode API
    
    /**
     Get current period information about the Mythic Challenge Mode relevant to Mythic Keystone Leaderboards
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicChallengeMode(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/mythic-challenge-mode/"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Playable Class API
    
    /**
     Get an index of playable classes
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPlayableClasses(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/playable-class/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Get a playable class by id
     
     - parameter id: The id of a playable class
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPlayableClass(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/playable-class/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns the PvP talent slots for a playable class by ID.et a playable class by id
     
     - parameter id: The id of a playable class
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPlayableClassPvPTalentSlots(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/playable-class/\(id)/pvp-talent-slots"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Playable Specialization API
    
    /**
     Get an index of playable specializations
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPlayableSpecializations(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/playable-specialization/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Get a playable specialization by id
     
     - parameter id: The id of a playable specialization
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPlayableSpecialization(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/playable-specialization/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Power Type API
    
    /**
     Returns an index of power types
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPowerTypes(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/power-type/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns a power type by ID
     
     - parameter id: The ID of the power type
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPowerType(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/power-type/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    // MARK: Playable Race API
    
    /**
     Returns an index of races
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPlayableRaces(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/race/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns a race by ID
     
     - parameter id: The ID of the race
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPlayableRace(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/race/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "static")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Realm API
    
    /**
     Get an index of realms
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getRealmIndex(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/realm/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Get a single realm by slug or id
     
     - parameter slug: The slug of the realm
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getRealm(_ slug: String, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/realm/\(slug)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Region API
    
    /**
     Get an index of regions
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getRegionIndex(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/region/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Get a single region by id
     
     - parameter id: The id of the region
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getRegion(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/region/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Token API
    
    /**
     Get the WoW Token index
     
     - parameter region: What region the request is being made
     - parameter locale: The locale that should be reflected in localized data
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getTokenIndex(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .gameData
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/token/index"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "dynamic")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: - Profile API
    
    /**
     This provides data about the current logged in OAuth user's WoW profile.
     
     - parameter region: What region the request is being made
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    public func getCharacters(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.characters) { result in
            completion(result)
        }
    }
    
    
    // MARK: WoW Mythic Keystone Character Profile API
    
    /**
     Returns a Mythic Keystone Profile index for a character.
     
     - note: This request returns a 404 for characters that have not completed a Mythic Keystone dungeon.
     
     - parameter characterName: The lowercase name of the character
     - parameter realmSlug: The slug of the realm
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    public func getMythicKeystoneProfile(characterName: String, realmSlug: String, namespace: APINamespace? = nil, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        call(endpoint: API.mythicKeystoneProfile(realmSlug: realmSlug, characterName: characterName), namespace: .profile) { result in
            completion(result)
        }
    }
    
    
    /**
     Returns a Mythic Keystone Profile index for a character.
     
     - note: This request returns a 404 for characters that have not completed a Mythic Keystone dungeon.
     
     - parameter seasonID: The ID of the Mythic Keystone season
     - parameter characterName: The lowercase name of the character
     - parameter realmSlug: The slug of the realm
     - parameter region: What region the request is being made
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getMythicKeystoneProfileSeason(seasonID: Int, characterName: String, realmSlug: String, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .profile
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/character/\(realmSlug)/\(characterName)/mythic-keystone-profile/season/\(seasonID)"
        urlStr = appendSharedURLParameters(to: urlStr, withNamespace: "profile")
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: .profile) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: - Community API
    
    // MARK: Challenge Mode API
    
    /**
     The data in this request has data for all 9 challenge mode maps (currently). The map field includes the current medal times for each dungeon. Inside each ladder we provide data about each character that was part of each run. The character data includes the current cached spec of the character while the member field includes the spec of the character during the challenge mode run.
     
     - parameter realm: The realm being requested
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getChallengeLeaderboards(realm: String, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/challenge/\(realm)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The region leaderboard has the exact same data format as the realm leaderboards except there is no realm field. It is simply the top 100 results gathered for each map for all of the available realm leaderboards in a region.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getTopChallengeLeaderboards(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/challenge/region"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Character Profile API
    
    /**
     The Character Profile API is the primary way to access character information. By default, a basic dataset will be returned with each request and zero or more additional fields can be retrieved.
     
     - parameter name: The name of the character you want to retrieve
     - parameter realm: The character's realm. Can be provided as the proper realm name or the normalized realm name
     - parameter fields: The dataset you wish to retrieve for the character. Each field value is explained in more detail in the following methods. If no fields are specified the API will only return basic data about the character
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getCharacter(_ name: String, realm: String, fields: [String]?, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/character/\(realm)/\(name)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        if var url = URL(string: urlStr),
            let fields = fields {
            url.appendQuery(parameters: ["fields": fields.joined(separator: ",")])
            urlStr = url.absoluteString
        }
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    // MARK: Guild Profile API
    
    /**
     The Character Profile API is the primary way to access character information. By default, a basic dataset will be returned with each request and zero or more additional fields can be retrieved.
     
     - parameter name: Name of the guild being queried
     - parameter realm: The realm the guild lives on
     - parameter fields: The optional data you want to retrieve about the guild. If no fields are specified the API will only return basic data about the guild
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getGuild(_ name: String, realm: String, fields: [String]?, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/guild/\(realm)/\(name)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        if var url = URL(string: urlStr),
            let fields = fields {
            url.appendQuery(parameters: ["fields": fields.joined(separator: ",")])
            urlStr = url.absoluteString
        }
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Pet API
    
    /**
     A list of all supported battle and vanity pets.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPets(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/pet/"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     This provides data about a individual battle pet ability ID. We do not provide the tooltip for the ability yet. We are working on a better way to provide this since it depends on your pet's species, level and quality rolls.
     
     - parameter abilityID: The ID of the ability you want to retrieve
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPetAbility(abilityID: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/pet/ability/\(abilityID)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     This provides the data about an individual pet species. The species IDs can be found your character profile using the options pets field. Each species also has data about what it's 6 abilities are.
     
     - parameter speciesID: The species you want to retrieve data on
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPetSpecies(speciesID: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/pet/species/\(speciesID)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     Retrieve detailed information about a given species of pet.
     
     - parameter speciesID: The pet's species ID. This can be found by querying a users' list of pets via the Character Profile API.
     - parameter level: The pet's level. Pet levels max out at 25. If omitted the API assumes a default value of 1.
     - parameter breedID: The pet's breed. Retrievable via the Character Profile API. If omitted the API assumes a default value of 3.
     - parameter qualityID: The pet's quality. Retrievable via the Character Profile API. Pet quality can range from 0 to 5 (0 is poor quality and 5 is legendary). If omitted the API will assume a default value of 1.
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getPetStats(speciesID: Int, level: Int = 1, breedID: Int = 3, qualityID: Int = 1, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/pet/stats/\(speciesID)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        if var url = URL(string: urlStr) {
            url.appendQuery(parameters: ["level": "\(level)",
                                         "breedId": "\(breedID)",
                                         "qualityId": "\(qualityID)"])
            urlStr += url.absoluteString
        }
        
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: PVP API
    
    /**
     The Leaderboard API endpoint provides leaderboard information for the 2v2, 3v3, 5v5 and Rated Battleground leaderboards.
     
     - parameter bracket: The type of leaderboard you want to retrieve. Valid entries are `2v2`, `3v3`, `5v5`, and `rbg`
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getLeaderboard(bracket: String, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        guard bracket == "2v2" ||
            bracket == "3v3" ||
            bracket == "5v5" ||
            bracket == "rbg" else {
            completion(.failure(HTTPError.unexpectedBody))
            return
        }
        
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/leaderboard/\(bracket)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Quest API
    
    /**
     Retrieve metadata for a given quest.
     
     - parameter id: The ID of the desired quest
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getQuest(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/quest/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Realm Status API
    
    /**
     The realm status API allows developers to retrieve realm status information. This information is limited to whether or not the realm is up, the type and state of the realm, the current population, and the status of the two world PvP zones.
     
     There are no required query string parameters when accessing this resource, although the optional realms parameter can be used to limit the realms returned to a specific set of realms.
     
     PvP Area Status Fields
     
     `area` - An internal id of this zone.
     
     `controlling-faction` - Which faction is controlling the zone at the moment. Possible values are
     * 0: Alliance
     * 1: Horde
     * 2: Neutral
     
     `status` - The current status of the zone. The possible values are
     * -1: Unknown
     * 0: Idle
     * 1: Populating
     * 2: Active
     * 3: Concluded
     
     `next` - A timestamp of when the next battle starts.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getRealmsStatus(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/realm/status"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Recipe API
    
    /**
     The recipe API provides basic recipe information.
     
     - parameter id: Unique ID for the desired recipe
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getRecipe(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/recipe/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Spell API
    
    /**
     The spell API provides some information about spells.
     
     - parameter id: The ID of the spell you want to retrieve
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getSpell(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/spell/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Zone API
    
    /**
     A list of all supported zones and their bosses. A 'zone' in this context should be considered a dungeon, or a raid, not a zone as in a world zone. A 'boss' in this context should be considered a boss encounter, which may include more than one NPC.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getZones(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/zone/"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The Zone API provides some information about zones.
     
     - parameter id: The ID of the zone you want to retrieve
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getZone(id: Int, completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/zone/\(id)"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    
    // MARK: Data Resources
    
    /**
     The battlegroups data API provides the list of battlegroups for this region.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getBattlegroups(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/battlegroups/"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The character races data API provides a list of each race and their associated faction, name, unique ID, and skin.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getRaces(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/character/races"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The character classes data API provides a list of character classes.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
    */
    func getClasses(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/character/classes"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The character achievements data API provides a list of all of the achievements that characters can earn as well as the category structure and hierarchy.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getAchievements(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/character/achievements"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The guild rewards data API provides a list of all guild rewards.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getGuildRewards(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/guild/rewards"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The guild perks data API provides a list of all guild perks.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getGuildPerks(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/guild/perks"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The guild achievements data API provides a list of all of the achievements that guilds can earn as well as the category structure and hierarchy.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getGuildAchievements(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/guild/achievements"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The item classes data API provides a list of item classes.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getItemClasses(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/item/classes"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The talents data API provides a list of talents, specs and glyphs for each class.
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getTalents(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/talents"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
    
    
    /**
     The different bat pet types (including what they are strong and weak against)
     
     - parameter region: What region the request is being made
     - parameter locale: What locale to use in the response
     - parameter completion: Returns a Result with the Data if `success` or an HTTPError if `failure`
     */
    func getPetTypes(completion: @escaping (_ result: Result<Data, Error>) -> Void) {
        let apiType: APIType = .community
        var urlStr = getBaseURL(apiType: apiType)!.absoluteString + "/data/pet/types"
        urlStr = appendSharedURLParameters(to: urlStr)
        
        self.callWebService(urlStr: urlStr, method: .get, apiType: apiType) { result in
            completion(result)
        }
    }
}

