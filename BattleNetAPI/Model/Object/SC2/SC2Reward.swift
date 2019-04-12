//
//  SC2Reward.swift
//  BattleNetAPI
//
//  Created by Christopher Jennewein on 11/17/18.
//  Copyright © 2018 Prismatic Games. All rights reserved.
//

import Foundation


class SC2Reward: Codable {
    var id: String = ""
    var achievementID: String? = nil
    var name: String = ""

    var imageUrl: String = ""
    var isSkin: Bool = false
    var uiOrderHint: Int = 0
    var unlockableType: String = ""
    var flags: Int = 0
    var command: String? = nil
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case achievementID = "achievementId"
        case name
        case imageUrl
        case isSkin
        case uiOrderHint
        case unlockableType
        case flags
        case command
    }
}
