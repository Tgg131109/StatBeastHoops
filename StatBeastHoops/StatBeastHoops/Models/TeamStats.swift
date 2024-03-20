//
//  TeamStats.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/19/23.
//

import Foundation

struct TeamGame {
//    var date: Date
    var gameID: Int
    var sourceTeamID: Int
    var homeTeamID: Int
    var homeTeamScore: Int
    var awayTeamID: Int
    var awayTeamScore: Int
    var isPostseason: Bool
    
    var isHomeTeam: Bool {
        return sourceTeamID == homeTeamID ? true : false
    }
    
    var oppTeamID: Int {
        return isHomeTeam ? awayTeamID : homeTeamID
    }
    
    // determine if selected team won or loss
    // source team is the user selected team
    var outcome: String {
        let sourceTeamScore = sourceTeamID == homeTeamID ? homeTeamScore : awayTeamScore
        let oppTeamScore = sourceTeamID == homeTeamID ? awayTeamScore : homeTeamScore
        
        return sourceTeamScore > oppTeamScore ? "W" : "L"
    }
}
