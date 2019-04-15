//
//  Specialization.swift
//  BattleNetAPI
//
//  Created by Christopher Jennewein on 4/19/18.
//  Copyright © 2018 Prismatic Games. All rights reserved.
//

import Foundation


class SpecializationIndex: Codable {
    let _links: SelfLink<SpecializationIndex>
    let characterSpecializations: [KeyLink<Specialization>]
    let petSpecializations: [KeyLink<Specialization>]
    
    enum CodingKeys: String, CodingKey {
        case _links
        case characterSpecializations = "character_specializations"
        case petSpecializations = "pet_specializations"
    }
}



// https://us.api.battle.net/data/wow/playable-specialization/65?namespace=static-7.3.5_25875-us
class Specialization: Codable {
    let _links: SelfLink<Specialization>
    let id: Int
    let name: String

    let playableClass: KeyLink<WOWClass>
    let genderDescription: GenderName
    let role: Role
    let pvpTalents: [Talent]
    let talentTiers: [TalentTier]
    
    let media: MediaLink
    
    enum CodingKeys: String, CodingKey {
        case _links
        case id
        case playableClass = "playable_class"
        case name
        case genderDescription = "gender_description"
        case media
        case role
        case pvpTalents = "pvp_talents"
        case talentTiers = "talent_tiers"
    }
}



class Role: Codable {
    let type: String
    let name: String
}


class TalentTier: Codable {
    let level: Int
    let talents: [Talent]
}


class Talent: Codable {
    let talent: KeyLink<WOWClass>
    let spellTooltip: SpellTooltip
    
    enum CodingKeys: String, CodingKey {
        case talent
        case spellTooltip = "spell_tooltip"
    }
}


class SpellTooltip: Codable {
    let description: String
    let castTime: CastTime
    let cooldown: String?
    let powerCost: String?
    let range: Range?
    
    enum CodingKeys: String, CodingKey {
        case description
        case castTime = "cast_time"
        case cooldown
        case powerCost = "power_cost"
        case range
    }
}


enum CastTime: String, Codable {
    case channeled = "Channeled"
    case instant = "Instant"
    case passive = "Passive"
    case zeroFiveSecCast = "0.5 sec cast"
    case oneFiveSecCast = "1.5 sec cast"
    case oneSevenSecCast = "1.7 sec cast"
    case oneEightSecCast = "1.8 sec cast"
    case oneSecCast = "1 sec cast"
    case twoFiveSecCast = "2.5 sec cast"
    case twoSecCast = "2 sec cast"
    case threeSecCast = "3 sec cast"
}


enum Range: String, Codable {
    case meleeRange = "Melee Range"
    case tenYdRange = "10 yd range"
    case fifteenYdRange = "15 yd range"
    case twentyYdRange = "20 yd range"
    case thirtyYdRange = "30 yd range"
    case thirtyFiveYdRange = "35 yd range"
    case fortyYdRange = "40 yd range"
    case fiftyYdRange = "50 yd range"
    case fiveToTwentyFiveYdRange = "5-25 yd range"
    case SixtyYdRange = "60 yd range"
    case eightToTwentyFiveYdRange = "8-25 yd range"
    case eightYdRange = "8 yd range"
}



class CharacterSpecialization: Codable {
    let name: String
    let role: RoleType
    let backgroundImage: String
    let icon: String
    let description: String
    let order: Int
}
