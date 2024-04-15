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

//enum LineChartType: String, CaseIterable, Plottable {
//    case p1 = "Player 1"
//    case p2 = "Player 2"
//    
//    var color : Color {
//        switch self {
//        case .p1:
//            return Team.teamData.firstIndex(where: { })
//        }
//    }
//}
//struct PlayerHeadshot {
//    var playerID: Int
//    var pic: Image? = nil
//}
