//
//  Team2.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import Foundation
import SwiftUI

struct Team2 {
    var teamID: Int
    var abbr: String
    var homeTown: String
    var teamName: String
    var fullName: String
    var conference: String
    var division: String
    var logo: UIImage
    var priColor: UIColor
    var roster : [Player]? = []
    var wins: Int? = 0
    var loss: Int? = 0
    var divRank: Int? = 0
    var leagueRank: Int? = 0
    
    var record : String {
        return "\(wins ?? 0) - \(loss ?? 0)"
    }
    
    var standing : String {
        var str = String()
        
        switch divRank {
        case 1:
            str = "1st | "
        case 2:
            str = "2nd | "
        case 3:
            str = "3rd | "
        case 4:
            str = "4th | "
        case 5:
            str = "5th | "
        default:
            str = ""
        }
        
        return "\(str)\(division) Division"
    }
    
    var thumbnail : UIImage {
        return logo.scale(newWidth: 40).withRenderingMode(.alwaysOriginal)
    }
}

//extension Team2: Decodable {
//    enum CodingKeys: String, CodingKey {
//        case teamID = "TeamID"
////        case abbr = ""
////        case homeTown = ""
//        case teamName = "TeamName"
////        case fullName = ""
////        case conference = ""
////        case division = ""
////        case logo = ""
////        case priColor = ""
////        case roster = ""
//        case wins = "WINS"
//        case loss = "LOSSES"
//        case divRank = "DivisionRank"
//        case leagueRank = "LeagueRank"
//    }
//
//    enum LookupCodingKeys: CodingKey {
//        case results
//    }
//
//    init(from decoder: Decoder) throws {
//        let lookupContainer = try decoder.container(keyedBy: LookupCodingKeys.self)
//        var resultsContainer = try lookupContainer.nestedUnkeyedContainer(forKey: LookupCodingKeys.results)
//        let podcastContainer = try resultsContainer.nestedContainer(keyedBy: CodingKeys.self)
//        
//        self.teamID = try podcastContainer.decode(Int.self, forKey: .teamID)
//        self.teamName = try podcastContainer.decode(String.self, forKey: .teamName)
//        self.wins = try podcastContainer.decode(Int.self, forKey: .wins)
//        self.loss = try podcastContainer.decode(Int.self, forKey: .loss)
//        self.divRank = try podcastContainer.decode(Int.self, forKey: .divRank)
//        self.leagueRank = try podcastContainer.decode(Int.self, forKey: .leagueRank)
//        
////        let team = BaseTeamData.teamData.first(where: { $0.teamID == self.teamID })
//        
//        
////        var teamID: Int
////        var abbr: String
////        var homeTown: String
////        var teamName: String
////        var fullName: String
////        var conference: String
////        var division: String
////        var logo: UIImage
////        var priColor: UIColor
//        
//        var roster: [Player] = []
//        
//        while !resultsContainer.isAtEnd {
//            let player = try resultsContainer.decode(Player.self)
//            roster.append(player)
//        }
//        
//        self.roster = roster
//    }
//}

struct BaseTeamData {
    static var teamData : [Team2] = [
        Team2(teamID: 1610612737, abbr: "ATL", homeTown: "Atlanta", teamName: "Hawks", fullName: "Atlanta Hawks", conference: "East", division: "Southeast", logo: UIImage(named: "hawks")!, priColor: UIColor(red: 200/255, green: 16/255, blue: 16/255, alpha: 1)),
        Team2(teamID: 1610612738, abbr: "BOS", homeTown: "Boston", teamName: "Celtics", fullName: "Boston Celtics", conference: "East", division: "Atlantic", logo: UIImage(named: "celtics")!, priColor: UIColor(red: 0, green: 122/255, blue: 51/255, alpha: 1)),
        Team2(teamID: 1610612751, abbr: "BKN", homeTown: "Brooklyn", teamName: "Nets", fullName: "Brooklyn Nets", conference: "East", division: "Atlantic", logo: UIImage(named: "nets")!, priColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)),
        Team2(teamID: 1610612766, abbr: "CHA", homeTown: "Charlotte", teamName: "Hornets", fullName: "Charlotte Hornets", conference: "East", division: "Southeast", logo: UIImage(named: "hornets")!, priColor: UIColor(red: 29/255, green: 17/255, blue: 96/255, alpha: 1)),
        Team2(teamID: 1610612741, abbr: "CHI", homeTown: "Chicago", teamName: "Bulls", fullName: "Chicago Bulls", conference: "East", division: "Central", logo: UIImage(named: "bulls")!, priColor: UIColor(red: 206/255, green: 17/255, blue: 65/255, alpha: 1)),
        Team2(teamID: 1610612739, abbr: "CLE", homeTown: "Cleveland", teamName: "Cavaliers", fullName: "Cleveland Cavaliers", conference: "East", division: "Central", logo: UIImage(named: "cavs")!, priColor: UIColor(red: 134/255, green: 0, blue: 56/255, alpha: 1)),
        Team2(teamID: 1610612742, abbr: "DAL", homeTown: "Dallas", teamName: "Mavericks", fullName: "Dallas Mavericks", conference: "West", division: "Southwest", logo: UIImage(named: "mavs")!, priColor: UIColor(red: 0, green: 83/255, blue: 188/255, alpha: 1)),
        Team2(teamID: 1610612743, abbr: "DEN", homeTown: "Denver", teamName: "Nuggets", fullName: "Denver Nuggets", conference: "West", division: "Northwest", logo: UIImage(named: "nuggets")!, priColor: UIColor(red: 13/255, green: 34/255, blue: 64/255, alpha: 1)),
        Team2(teamID: 1610612765, abbr: "DET", homeTown: "Detroit", teamName: "Pistons", fullName: "Detroit Pistons", conference: "East", division: "Central", logo: UIImage(named: "pistons")!, priColor: UIColor(red: 200/255, green: 16/255, blue: 46/255, alpha: 1)),
        Team2(teamID: 1610612744, abbr: "GSW", homeTown: "Golden State", teamName: "Warriors", fullName: "Golden State Warriors", conference: "West", division: "Pacific", logo: UIImage(named: "warriors")!, priColor: UIColor(red: 29/255, green: 66/255, blue: 138/255, alpha: 1)),
        Team2(teamID: 1610612745, abbr: "HOU", homeTown: "Houston", teamName: "Rockets", fullName: "Houston Rockets", conference: "West", division: "Southwest", logo: UIImage(named: "rockets")!, priColor: UIColor(red: 206/255, green: 17/255, blue: 65/255, alpha: 1)),
        Team2(teamID: 1610612754, abbr: "IND", homeTown: "Indiana", teamName: "Pacers", fullName: "Indiana Pacers", conference: "East", division: "Central", logo: UIImage(named: "pacers")!, priColor: UIColor(red: 0, green: 45/255, blue: 98/255, alpha: 1)),
        Team2(teamID: 1610612746, abbr: "LAC", homeTown: "Los Angeles", teamName: "Clippers", fullName: "Los Angeles Clippers", conference: "West", division: "Pacific", logo: UIImage(named: "clippers")!, priColor: UIColor(red: 200/255, green: 16/255, blue: 46/255, alpha: 1)),
        Team2(teamID: 1610612747, abbr: "LAL", homeTown: "Los Angeles", teamName: "Lakers", fullName: "Los Angeles Lakers", conference: "West", division: "Pacific", logo: UIImage(named: "lakers")!, priColor: UIColor(red: 85/255, green: 37/255, blue: 130/255, alpha: 1)),
        Team2(teamID: 1610612763, abbr: "MEM", homeTown: "Memphis", teamName: "Grizzlies", fullName: "Memphis Grizzlies", conference: "West", division: "Southwest", logo: UIImage(named: "grizzlies")!, priColor: UIColor(red: 93/255, green: 118/255, blue: 169/255, alpha: 1)),
        Team2(teamID: 1610612748, abbr: "MIA", homeTown: "Miami", teamName: "Heat", fullName: "Miami Heat", conference: "East", division: "Southeast", logo: UIImage(named: "heat")!, priColor: UIColor(red: 152/255, green: 0, blue: 46/255, alpha: 1)),
        Team2(teamID: 1610612749, abbr: "MIL", homeTown: "Milwaukee", teamName: "Bucks", fullName: "Milwaukee Bucks", conference: "East", division: "Central", logo: UIImage(named: "bucks")!, priColor: UIColor(red: 0, green: 71/255, blue: 27/255, alpha: 1)),
        Team2(teamID: 1610612750, abbr: "MIN", homeTown: "Minnesota", teamName: "Timberwolves", fullName: "Minnesota Timberwolves", conference: "West", division: "Northwest", logo: UIImage(named: "timberwolves")!, priColor: UIColor(red: 12/255, green: 35/255, blue: 64/255, alpha: 1)),
        Team2(teamID: 1610612740, abbr: "NOP", homeTown: "New Orleans", teamName: "Pelicans", fullName: "New Orleans Pelicans", conference: "West", division: "Southwest", logo: UIImage(named: "pelicans")!, priColor: UIColor(red: 0, green: 22/255, blue: 65/255, alpha: 1)),
        Team2(teamID: 1610612752, abbr: "NYK", homeTown: "New York", teamName: "Knicks", fullName: "New York Knicks", conference: "East", division: "Atlantic", logo: UIImage(named: "knicks")!, priColor: UIColor(red: 0, green: 107/255, blue: 182/255, alpha: 1)),
        Team2(teamID: 1610612760, abbr: "OKC", homeTown: "Oklahoma City", teamName: "Thunder", fullName: "Oklahoma City Thunder", conference: "West", division: "Northwest", logo: UIImage(named: "thunder")!, priColor: UIColor(red: 0, green: 125/255, blue: 195/255, alpha: 1)),
        Team2(teamID: 1610612753, abbr: "ORL", homeTown: "Orlando", teamName: "Magic", fullName: "Orlando Magic", conference: "East", division: "Southeast", logo: UIImage(named: "magic")!, priColor: UIColor(red: 0, green: 125/255, blue: 197/255, alpha: 1)),
        Team2(teamID: 1610612755, abbr: "PHI", homeTown: "Philadelphia", teamName: "76ers", fullName: "Philadelphia 76ers", conference: "East", division: "Atlantic", logo: UIImage(named: "sixers")!, priColor: UIColor(red: 0, green: 107/255, blue: 182/255, alpha: 1)),
        Team2(teamID: 1610612756, abbr: "PHX", homeTown: "Phoenix", teamName: "Suns", fullName: "Phoenix Suns", conference: "West", division: "Pacific", logo: UIImage(named: "suns")!, priColor: UIColor(red: 29/255, green: 17/255, blue: 96/255, alpha: 1)),
        Team2(teamID: 1610612757, abbr: "POR", homeTown: "Portland", teamName: "Trail Blazers", fullName: "Portland Trail Blazers", conference: "West", division: "Northwest", logo: UIImage(named: "trailblazers")!, priColor: UIColor(red: 224/255, green: 58/255, blue: 62/255, alpha: 1)),
        Team2(teamID: 1610612758, abbr: "SAC", homeTown: "Sacramento", teamName: "Kings", fullName: "Sacramento Kings", conference: "West", division: "Pacific", logo: UIImage(named: "kings")!, priColor: UIColor(red: 91/255, green: 43/255, blue: 130/255, alpha: 1)),
        Team2(teamID: 1610612759, abbr: "SAS", homeTown: "San Antonio", teamName: "Spurs", fullName: "San Antonio Spurs", conference: "West", division: "Southwest", logo: UIImage(named: "spurs")!, priColor: UIColor(red: 196/255, green: 206/255, blue: 211/255, alpha: 1)),
        Team2(teamID: 1610612761, abbr: "TOR", homeTown: "Toronto", teamName: "Raptors", fullName: "Toronto Raptors", conference: "East", division: "Atlantic", logo: UIImage(named: "raptors")!, priColor: UIColor(red: 206/255, green: 17/255, blue: 65/255, alpha: 1)),
        Team2(teamID: 1610612762, abbr: "UTA", homeTown: "Utah", teamName: "Jazz", fullName: "Utah Jazz", conference: "West", division: "Northwest", logo: UIImage(named: "jazz")!, priColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1)),
        Team2(teamID: 1610612764, abbr: "WAS", homeTown: "Washington", teamName: "Wizards", fullName: "Washington Wizards", conference: "East", division: "Southeast", logo: UIImage(named: "wizards")!, priColor: UIColor(red: 0, green: 43/255, blue: 92/255, alpha: 1)),
        Team2(teamID: 31, abbr: "NBA", homeTown: "National", teamName: "Basketball Association", fullName: "NBA", conference: "", division: "", logo: UIImage(named: "nba")!, priColor: UIColor(red: 29/255, green: 66/255, blue: 138/255, alpha: 1))
    ]
}
