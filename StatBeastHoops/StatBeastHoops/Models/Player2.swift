//
//  Player2.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import Foundation

// roster player
struct Player2 {
    var playerID: Int
    var playerName: String
//    var firstName: String
//    var lastName: String
    var nickName: String? = ""
    var age: Int? = -1
    var rank: Int? = -1
    var teamID: Int
    var jersey: String? = "-1"
    var position: String? = "UNK"
    var height: String? = "0-0"
    var weight: String? = "0"
    var birthDate: String? = "UNK"
    var exp: String? = "UNK"
    var college: String? = "UNK"
    var country: String? = "UNK"
    var draftYear: Int? = -1
    var draftNum: Int? = -1
    var draftRound: Int? = -1
    var rosterStatus: String? = "UNK"
    var howAcquired: String? = "UNK"
}

extension Player2: Decodable {
    enum CodingKeys: String, CodingKey {
        case playerID = "PLAYER_ID"
        case playerName = "PLAYER"
//        case lastName = "PLAYER_LAST_NAME"
        case nickName = "NICKNAME"
        case age = "AGE"
//        case rank = ""
        case teamID = "TeamID"
        case jersey = "NUM"
        case position = "POSITION"
        case height = "HEIGHT"
        case weight = "WEIGHT"
        case birthDate = "BIRTH_DATE"
        case exp = "EXP"
        case college = "SCHOOL"
//        case country = "COUNTRY"
//        case draftYear = "DRAFT_YEAR"
//        case draftNum = "DRAFT_NUMBER"
//        case draftRound = "DRAFT_ROUND"
//        case rosterStatus = "LeagueRank"
        case howAcquired = "HOW_ACQUIRED"
    }

    enum LookupCodingKeys: CodingKey {
        case results
    }

    init(from decoder: Decoder) throws {
        let lookupContainer = try decoder.container(keyedBy: LookupCodingKeys.self)
        var resultsContainer = try lookupContainer.nestedUnkeyedContainer(forKey: LookupCodingKeys.results)
        let podcastContainer = try resultsContainer.nestedContainer(keyedBy: CodingKeys.self)
        
        self.playerID = try podcastContainer.decode(Int.self, forKey: .playerID)
        self.playerName = try podcastContainer.decode(String.self, forKey: .playerName)
        self.nickName = try podcastContainer.decode(String.self, forKey: .nickName)
        self.age = try podcastContainer.decode(Int.self, forKey: .age)
        self.teamID = try podcastContainer.decode(Int.self, forKey: .teamID)
        self.jersey = try podcastContainer.decode(String.self, forKey: .jersey)
        self.position = try podcastContainer.decode(String.self, forKey: .position)
        self.height = try podcastContainer.decode(String.self, forKey: .height)
        self.weight = try podcastContainer.decode(String.self, forKey: .weight)
        self.birthDate = try podcastContainer.decode(String.self, forKey: .birthDate)
        self.exp = try podcastContainer.decode(String.self, forKey: .exp)
        self.college = try podcastContainer.decode(String.self, forKey: .college)
        self.howAcquired = try podcastContainer.decode(String.self, forKey: .howAcquired)
        
//        let team = BaseTeamData.teamData.first(where: { $0.teamID == self.teamID })
    }
}
