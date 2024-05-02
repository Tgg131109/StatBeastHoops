//
//  Game.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/11/24.
//

import Foundation
import SwiftUI

struct Game {
    var id: String
    var status: String
    var clock: String
    var time: String
    var homeTeamID: Int
    var awayTeamID: Int
    var homeTeamScore: Int
    var awayTeamScore: Int
}

struct GameStats : Identifiable {
    var id: String { gameID }
    
    var gameID: String
    var gameDate: String
    var matchup: String
    var wl: String
    var min: Double? = -1
    var fgm: Double? = -1
    var fga: Double? = -1
    var fg_pct: Double? = -1
    var fg3m: Double? = -1
    var fg3a: Double? = -1
    var fg3_pct: Double? = -1
    var ftm: Double? = -1
    var fta: Double? = -1
    var ft_pct: Double? = -1
    var oreb: Double? = -1
    var dreb: Double? = -1
    var reb: Double? = -1
    var ast: Double? = -1
    var stl: Double? = -1
    var blk: Double? = -1
    var blka: Double? = -1
    var tov: Double? = -1
    var pf: Double? = -1
    var pfd: Double? = -1
    var pts: Double? = -1
    var pm: Double? = -1
    var fantasyPts: Double? = -1
    var DD2: Double? = -1
    var TD3: Double? = -1
    
    var vsTeamID: Int {
        var vtID = -1
        let matchupArr = matchup.components(separatedBy: " ")
        
        if let tID = Team.teamData.first(where: { $0.abbr == matchupArr.last })?.teamID {
            vtID = tID
        }
        
        return vtID
    }
    
    var vsTeam: Team {
        var vt = Team.teamData[30]
        let matchupArr = matchup.components(separatedBy: " ")
        
        if let t = Team.teamData.first(where: { $0.abbr == matchupArr.last }) {
            vt = t
        }
        
        return vt
    }
    
    var homeAway: String {
        let matchupArr = matchup.components(separatedBy: " ")
        
        if matchupArr[1] == "@" {
            return "Away"
        } else {
            return "Home"
        }
    }
    
    var score: String {
        let pts1 = Int(pts ?? 0)
        let pts2 = Int((pts ?? 0) - (pm ?? 0))
        
        if homeAway == "Home" {
            return "\(pts1) - \(pts2)"
        } else {
            return "\(pts2) - \(pts1)"
        }
    }
}
