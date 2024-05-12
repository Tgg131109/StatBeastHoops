//
//  PlayerCompareViewModel.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import Foundation
import SwiftUI

@MainActor
class PlayerCompareViewModel : ObservableObject {
    @Published var showCompareSetup = false
    
    @Published var allPlayers = [Player]()
    @Published var historicalPlayers = [Player]()
    @Published var inactivePlayers = [Player]()
    
//    @Published var statCompare = [StatCompare]()
//    @Published var gameStatCompare = [StatSeriesCompare]()
//    @Published var gameStats = [StatSeriesAll]()
//    @Published var currentDetent = PresentationDetent.height(400)
//    @Published var needsOverlay = true
//    @Published var showComparePage = false
    
    func getAllPlayers() async {
        // playerindex endpoint (set Active=1 for only current players)
        // This is just player info, no stats.
        allPlayers.removeAll()
//        progress = 0.0
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playerindex?Active=&AllStar=&College=&Country=&DraftPick=&DraftRound=&DraftYear=&Height=&Historical=1&LeagueID=00&Season=2023-24&TeamID=0&Weight=")
        else { fatalError("Invalid URL")}
        
        var urlRequest = URLRequest(url: validURL)
        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
        //        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (validData, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 // 200 = OK
            else {
                DispatchQueue.main.async {
                    // Present alert on main thread if there is an error with the URL.
                }
                
                print("JSON object creation failed.")
                return
            }
            
            // Calculate the total size of the response data for progress tracking
            let totalSize = Float(response.expectedContentLength)
            var receivedSize: Float = 0.0
            //            print(response.progress)
            //
            //            for try await byte in validData.count {
            //                        data.append(byte)
            //                        let progress = Double(data.count) / Double(totalSize)
            //                        print(progress)
            //                    }
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["resultSets"] as? [[String: Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                guard let headers = data[0]["headers"] as? [Any],
                      let players = data[0]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                for player in players {
                    //                        DispatchQueue.main.async {
                    //                            Update progress
                    receivedSize += Float(MemoryLayout.size(ofValue: player))
                    //                        print(receivedSize)
//                    self.progress = Double(receivedSize / totalSize)
                    //                        print(progress)
                    //                    }
                    var i = 0
                    var p = [String : Any]()
                    
                    for header in headers {
                        p[header as! String] = player[i]
                        i += 1
                    }
                    
                    let newPlayer = Player(playerID: p["PERSON_ID"] as! Int, firstName: p["PLAYER_FIRST_NAME"] as! String, lastName: p["PLAYER_LAST_NAME"] as! String, rank: 0, teamID: p["TEAM_ID"] as! Int, jersey: p["JERSEY_NUMBER"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, college: p["COLLEGE"] as? String, country: p["COUNTRY"] as? String, draftYear: p["DRAFT_YEAR"] as? Int, draftNum: p["DRAFT_NUMBER"] as? Int, draftRound: p["DRAFT_ROUND"] as? Int)
                    
                    self.allPlayers.append(newPlayer)
                    
                    if let x = Team.teamData.firstIndex(where: { $0.teamID == newPlayer.teamID }) {
                        if let i = Team.teamData[x].roster?.firstIndex(where: { $0.playerID == newPlayer.playerID }) {
                            Team.teamData[x].roster?[i].draftYear = newPlayer.draftYear
                            Team.teamData[x].roster?[i].draftRound = newPlayer.draftRound
                            Team.teamData[x].roster?[i].draftNum = newPlayer.draftNum
                            Team.teamData[x].roster?[i].country = newPlayer.country
                            
//                            print("found \(Team.teamData[x].roster?[i].firstName) \(Team.teamData[x].roster?[i].lastName)")
//                            print("year - \(Team.teamData[x].roster?[i].draftYear) | round - \(Team.teamData[x].roster?[i].draftRound) | number - \(Team.teamData[x].roster?[i].draftNum)")
//                            print("year - \(p["DRAFT_YEAR"] as? Int)) | round - \(p["DRAFT_ROUND"] as? Int)) | number - \(p["DRAFT_NUMBER"] as? Int)")
                        } else {
//                            print("player not found on a team - \(newPlayer.firstName) \(newPlayer.lastName)")
                            self.inactivePlayers.append(newPlayer)
                        }
                    } else {
//                        print("no team found for player - \(newPlayer.firstName) \(newPlayer.lastName)")
                        self.historicalPlayers.append(newPlayer)
                    }
                }
            }
        } catch {
            return
        }
    }
}
