//
//  PlayerStats.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/19/23.
//

import Foundation
import SwiftUI

struct PlayerStats {
    var playerID: Int
    var seasonStats: [String : SeasonStats]
}

struct SeasonStats : Identifiable {
    let id = UUID()
    
//    var playerID: Int
//    var seasons: [String]
    var age: Int? = -1
    var gp: Double? = -1
    var gs: Double? = -1
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
    var tov: Double? = -1
    var pf: Double? = -1
    var pts: Double? = -1
    var eff: Double? = -1
}

struct PlayerGameStats {
    var playerID: Int
    var season: String
    var gameStats: [GameStats]
}

struct PlayerStat {
    var id: Int
    var stat: String
    var value: String
}

struct StatCompare: Hashable {
    var id: Int
    var stat: String
    
    // Overall stats
    var value1: String // Player 1/on
    var value2: String // Player 2/off
    
//    // Player 1 vs opponent
//    var value3: String // opponent on court
//    var value4: String // opponent off court
//    
//    // Player 2 vs opponent
//    var value5: String // opponent on court
//    var value6: String // opponent off court
}

struct StatSeriesAll: Identifiable {
    var id: String // Will be used for each player being compared.
    var statData: [PlayerStatSeries]
}

struct StatSeriesCompare: Identifiable {
    var id: String // Will be used for each player being compared.
    var statSeries: [Stat]
    var color: Color
}

struct PlayerStatSeries {
//        var id: Int
    var category: String
    var statData: [Stat]
}

struct Stat: Identifiable {
    var id: Int // = game number to get data sets together.
    var value: String
}

// MARK: New player stats setup
// NextGame ['GAME_ID', 'GAME_DATE', 'GAME_TIME', 'LOCATION', 'PLAYER_TEAM_ID', 'PLAYER_TEAM_CITY', 'PLAYER_TEAM_NICKNAME', 'PLAYER_TEAM_ABBREVIATION', 'VS_TEAM_ID', 'VS_TEAM_CITY', 'VS_TEAM_NICKNAME', 'VS_TEAM_ABBREVIATION']
// SeasonTotals ['PLAYER_ID', 'SEASON_ID', 'LEAGUE_ID', 'TEAM_ID', 'TEAM_ABBREVIATION', 'PLAYER_AGE', 'GP', 'GS', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS']
// CareerTotals ['PLAYER_ID', 'LEAGUE_ID', 'TEAM_ID', 'GP', 'GS', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS']
// Player -> PlayerSeasonStats = [SeasonType(Pre/Regular/Post/AllStar) : [SeasonID(year) : [SeasonStats]]]
// Player -> PlayerCareerStats = [SeasonType(Pre/Regular/Post/AllStar) : [CareerStats]]
// Player -> SeasonHighs = [Highs]
// Player -> CareerHighs = [Highs]

struct PlayerSeasonStats: Decodable, Encodable {
    var seasonType: String
    var seasonStats: [String : StatTotals]
//    var seasonHighs: [String : Highs]
    var seasonRankings: [String : Rankings]
}

struct PlayerCareerStats: Decodable, Encodable {
    var seasonType: String
    var careerStats: [StatTotals]
}

struct StatTotals: Decodable, Encodable {
    var age: Int?
    var teamID: Int?
    var gp: Int
    var gs: Int
    var min: Int
    var fgm: Int
    var fga: Int
    var fg_pct: Double
    var fg3m: Int
    var fg3a: Int
    var fg3_pct: Double
    var ftm: Int
    var fta: Int
    var ft_pct: Double
    var oreb: Int
    var dreb: Int
    var reb: Int
    var ast: Int
    var stl: Int
    var blk: Int
    var tov: Int
    var pf: Int
    var pts: Int
    
    var all: [String] {
        return ["\(gp)", "\(gs)", "\(min)", "\(fgm)", "\(fga)", String(format: "%.1f", (Double(fg_pct)) * 100), "\(fg3m)", "\(fg3a)", String(format: "%.1f", (Double(fg3_pct)) * 100), "\(ftm)", "\(fta)", String(format: "%.1f", (Double(ft_pct)) * 100), "\(oreb)", "\(dreb)", "\(reb)", "\(ast)", "\(stl)", "\(blk)", "\(tov)", "\(pf)", "\(pts)"]
    }
    
    var avg: [String] {
        var a : [String] = []
        let pct = [5, 8, 11] // Indicies for pct stats
        
        for i in all.indices {
            if i < 2 {
                a.append("-")
            } else if !pct.contains(i) {
                a.append(String(format: "%.1f", Double((Double(all[i]) ?? 0)/Double(gp))))
            } else {
//                let vm = Int(all[i - 2] ?? 0)
//                let va = Int(all[i - 1] ?? 0)
                let v = (Double(a[i - 2]) ?? 0)/(Double(a[i - 1]) ?? 0)
//                let vp = vm/va
                a.append(String(format: "%.1f", (Double(v) * 100)))
//                if i == 5 {
//                    a.append(String(format: "%.1f", Double((Int(all[3] ?? 0)/Int(all[4] ?? 0)) * 100)))
//                } else if i == 8 {
//                    a.append(String(format: "%.1f", Double((Int(all[6] ?? 0)/Int(all[7] ?? 0)) * 100)))
//                } else {
//                    a.append(String(format: "%.1f", Double((Int(all[9] ?? 0)/Int(all[10] ?? 0)) * 100)))
//                }
            }
        }
        
        return a
    }
}

struct Rankings: Decodable, Encodable {
    var gp: String
    var gs: String
    var min: Int?
    var fgm: Int?
    var fga: Int?
    var fg_pct: Int?
    var fg3m: Int?
    var fg3a: Int?
    var fg3_pct: Int?
    var ftm: Int?
    var fta: Int?
    var ft_pct: Int?
    var oreb: Int?
    var dreb: Int?
    var reb: Int?
    var ast: Int?
    var stl: Int?
    var blk: Int?
    var tov: Int?
    var pts: Int?
    var eff: Int?
    
    var all: [String] {
        return ["\(gp)", "\(gs)", "\(min ?? -1)", "\(fgm ?? -1)", "\(fga ?? -1)", "\(fg_pct ?? -1)", "\(fg3m ?? -1)", "\(fg3a ?? -1)", "\(fg3_pct ?? -1)", "\(ftm ?? -1)", "\(fta ?? -1)", "\(ft_pct ?? -1)", "\(oreb ?? -1)", "\(dreb ?? -1)", "\(reb ?? -1)", "\(ast ?? -1)", "\(stl ?? -1)", "\(blk ?? -1)", "\(tov ?? -1)", "\(pts ?? -1)", "\(eff ?? -1)"]
    }
}

struct PlayerCompare {
    var matchup: Matchup
    
    var statCompare: [StatCompare]
    var onOffCourtP1: [StatCompare]
    var onOffCourtP2: [StatCompare]
    var oppOnCourt: [StatCompare]
    var oppOffCourt: [StatCompare]
    
    var p1GameStats: [GameStats]
    var p2GameStats: [GameStats]
    var p1StatTotals: StatTotals?
    var p2StatTotals: StatTotals?
}


