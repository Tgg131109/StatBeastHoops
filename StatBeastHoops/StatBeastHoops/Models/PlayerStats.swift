//
//  PlayerStats.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/19/23.
//

import Foundation
import SwiftUI

struct PlayerStats : Decodable, Encodable {
    var playerID: Int
    var age: Int? = -1
    var gp: Int? = -1
    var gs: Int? = -1
    var min: Int? = -1
    var fgm: Int? = -1
    var fga: Int? = -1
    var fg_pct: Int? = -1
    var fg3m: Int? = -1
    var fg3a: Int? = -1
    var fg3_pct: Int? = -1
    var ftm: Int? = -1
    var fta: Int? = -1
    var ft_pct: Int? = -1
    var oreb: Int? = -1
    var dreb: Int? = -1
    var reb: Int? = -1
    var ast: Int? = -1
    var stl: Int? = -1
    var blk: Int? = -1
    var tov: Int? = -1
    var pf: Int? = -1
    var pts: Int? = -1
    var eff: Int? = -1
}

struct PlayerStat {
    var id: Int
    var stat: String
    var value: String
}

struct StatCompare: Hashable {
    var id: Int
    var stat: String
    var value1: String
    var value2: String
}

struct StatSeriesAll: Identifiable {
    var id: String // Will be used for each player being compared.
    var statData: [PlayerStatSeries]
}

struct StatSeriesCompare: Identifiable {
    var id: String // Will be used for each player being compared.
    var statSeries: [Stat]
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

//struct PlayerHeadshot {
//    var playerID: Int
//    var pic: Image? = nil
//}
