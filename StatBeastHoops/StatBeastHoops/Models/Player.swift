//
//  Player.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/11/23.
//

import Foundation
//import UIKit
import SwiftUI

struct Player: Decodable, Encodable, Identifiable {
    var id: String { String(playerID) }
    
    var playerID: Int
    var firstName: String
    var lastName: String
    var nickName: String? = ""
    var age: Int? = -1
    var rank: Int? = -1
    var teamID: Int
    var jersey: String? = "-1"
    var position: String? = "UNK"
    var height: String? = "0-0"
    var weight: String? = "0"
    var birthDate: String? = "UNK"
    var experience: String? = "UNK"
    var college: String? = "UNK"
    var country: String? = "UNK"
    var draftYear: Int? = -1
    var draftNum: Int? = -1
    var draftRound: Int? = -1
    var rosterStatus: String? = "UNK"
    var howAcquired: String? = "UNK"
    
    var seasonStats: [PlayerSeasonStats]? = []
    var careerStats: [PlayerCareerStats]? = []
    
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
    
    var ht : String {
        let heightArr = height?.split(separator: "-")
        
        return "\(heightArr?[0] ?? "-")'\(heightArr?[1] ?? "-")\""
    }
    
    var wt : String {
        return "\(weight ?? "-") lbs"
    }
    
    var attr : String {
        let heightArr = height?.split(separator: "-")
        
        return "\(heightArr?[0] ?? "-")'\(heightArr?[1] ?? "-")\" | \(weight ?? "-") lbs | \(age ?? 0) years old"
    }
    
    var draft : String {
        return "\(draftYear ?? -1) R\(draftRound ?? -1) Pick \(draftNum ?? -1) "
    }
    
    var exp : String {
        var str = experience
        
        guard let s = Int(experience!)
        else {
            return str!
        }
        
        if s == 1 {
            str = "1 season"
        } else if s > 1{
            str = "\(s) seasons"
        }
        
        return str!
    }
    
    var team : Team {
        return Team.teamData.first(where: { $0.teamID == teamID }) ?? Team.teamData[30]
    }
    
//    var headshot : Image {
//        if let hs = pic {
//            return hs
//        } else {
//            // Download image
//            var headshotView: some View {
//                AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { phase in
//                    switch phase {
//                    case .empty:
//                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//                    case .success(let image):
//                        let _ = DispatchQueue.main.async {
//                            playerDataManager.playerHeadshots.append(PlayerHeadshot(playerID: player.playerID, pic: image))
//                        }
//                        
//                        image.resizable().scaledToFit()
//                    case .failure:
//                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//                    @unknown default:
//                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//                    }
//                }
//                .frame(width: 80, height: 60, alignment: .bottom)
//                .padding(.trailing, -20)
//            }
//        }
//    }
//    var stats : PlayerStats {
//        
//    }
}

struct PlayerHeadshot {
    var playerID: Int
    var pic: Image
}

// These are prepopulated to minimize API calls.
extension Player {
    static let demoPlayer : Player = Player(playerID: 202710, firstName: "Jimmy", lastName: "Butler", nickName: "Jimmy", age: 34, rank: 0, teamID: 1610612748, jersey: "22", position: "F", height: "6-7", weight: "230", birthDate: "SEP 14, 1989", experience: "12", college: "Marquette")
    
    static let emptyData : [Any] = ["DataSet", "name", "id", "name", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    static let emptyVsData : [Any] = ["vs Player", "id", "name", "vs id", "vs PlayerName", "onOff", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    static let popularPlayers : [Player] = [
//        Player(playerID: 15, firstName: "Giannis", lastName: "Antetokounmpo", heightFt: 6, heightIn: 11, position: "F", teamID: 17),
//        Player(playerID: 140, firstName: "Kevin", lastName: "Durant", heightFt: 6, heightIn: 9, position: "F", teamID: 24),
//        Player(playerID: 115, firstName: "Stephen", lastName: "Curry", heightFt: 6, heightIn: 3, position: "G", teamID: 10),
//        Player(playerID: 246, firstName: "Nikola", lastName: "Jokic", heightFt: 7, heightIn: 0, position: "C", teamID: 8),
//        Player(playerID: 145, firstName: "Joel", lastName: "Embiid", heightFt: 7, heightIn: 0, position: "F-C", teamID: 23),
//        Player(playerID: 434, firstName: "Jayson", lastName: "Tatum", heightFt: 6, heightIn: 8, position: "F", teamID: 2),
//        Player(playerID: 132, firstName: "Luka", lastName: "Doncic", heightFt: 6, heightIn: 11, position: "F-G", teamID: 7),
//        Player(playerID: 237, firstName: "Lebron", lastName: "James", heightFt: 6, heightIn: 8, position: "F", teamID: 14),
//        Player(playerID: 666786, firstName: "Ja", lastName: "Morant", position: "G", teamID: 15),
//        Player(playerID: 247, firstName: "Kawhi", lastName: "Leonard", heightFt: 6, heightIn: 7, position: "F", teamID: 13)
    ]
}
