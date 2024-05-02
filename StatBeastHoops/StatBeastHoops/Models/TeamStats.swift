//
//  TeamStats.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/19/23.
//

import Foundation

struct TeamStats: Identifiable {
    var id: ObjectIdentifier
    
//    LeagueID : 00
//    SeasonID : 22023
//    TeamID : 1610612738
//    TeamCity : Boston
//    TeamName : Celtics
//    Conference : East
//    ConferenceRecord : 41-11
//    PlayoffRank : 1
//    ClinchIndicator :  - e
//    Division : Atlantic
//    DivisionRecord : 15-2
//    DivisionRank : 1
//    WINS : 64
//    LOSSES : 18
//    WinPCT : 0.78
//    LeagueRank : 3
//    Record : 64-18
//    HOME : 37-4
//    ROAD : 27-14
//    L10 : 7-3
//    Last10Home : 9-1
//    Last10Road : 7-3
//    OT : 2-4
//    ThreePTSOrLess : 6-7
//    TenPTSOrMore : 42-5
//    LongHomeStreak : 20
//    strLongHomeStreak : W 20
//    LongRoadStreak : 8
//    strLongRoadStreak : W 8
//    LongWinStreak : 11
//    LongLossStreak : 2
//    CurrentHomeStreak : 2
//    strCurrentHomeStreak : W 2
//    CurrentRoadStreak : -1
//    strCurrentRoadStreak : L 1
//    CurrentStreak : 2
//    strCurrentStreak : W 2
//    ConferenceGamesBack : 0
//    DivisionGamesBack : 0
//    ClinchedConferenceTitle : 1
//    ClinchedDivisionTitle : 1
//    ClinchedPlayoffBirth : 1
//    EliminatedConference : 0
//    EliminatedDivision : 0
//    AheadAtHalf : 56-11
//    BehindAtHalf : 8-7
//    TiedAtHalf : 0-0
//    AheadAtThird : 59-6
//    BehindAtThird : 4-12
//    TiedAtThird : 1-0
//    Score100PTS : 64-15
//    OppScore100PTS : 49-18
//    OppOver500 : 38-13
//    LeadInFGPCT : 56-2
//    LeadInReb : 43-6
//    FewerTurnovers : 31-9
//    PointsPG : 120.6
//    OppPointsPG : 109.2
//    DiffPointsPG : 11.3
//    vsEast : 41-11
//    vsAtlantic : 15-2
//    vsCentral : 13-5
//    vsSoutheast : 13-4
//    vsWest : 23-7
//    vsNorthwest : 6-4
//    vsPacific : 7-3
//    vsSouthwest : 10-0
//    Jan : 11-5
//    Feb : 9-1
//    Mar : 12-4
//    Apr : 6-2
//    May : <null>
//    Jun : <null>
//    Jul : <null>
//    Aug : <null>
//    Sep : <null>
//    Oct : 3-0
//    Nov : 11-4
//    Dec : 12-2
//    PreAS : 43-12
//    PostAS : 21-6
}

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

