//
//  PlayerDataManager.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/31/24.
//

import Foundation
import SwiftUI

@MainActor
class PlayerDataManager : ObservableObject {
    @Published var allPlayers = [Player]()
    @Published var leaders = [Player]()
    @Published var playerHeadshots = [PlayerHeadshot]()
    
    
//    @Published var isTaskRunning = true
    
    
    
    @Published var searchResults = [Player]()
    @Published var statCriteria = [String]()
    @Published var statCompare = [StatCompare]()
    @Published var gameStatCompare = [StatSeriesCompare]()
    @Published var gameStats = [StatSeriesAll]()
    @Published var teams = [Team]()
    @Published var seasons = [String]()
    @Published var teamRoster = [Player]()
    
    @Published var progress: Double = 0.0
    
    // Stat Compare
    @Published var sp : Player? = nil
    @Published var p1 : Player? = nil
    @Published var p2 : Player? = nil
    @Published var currentDetent = PresentationDetent.height(400)
    @Published var showComparePage = false

    
    @Published var showSettingsPage = false
    
    @Published var playerStats = [PlayerStats]()
    
//    @MainActor
    func getAllPlayers() async {
        allPlayers.removeAll()
//        isTaskRunning = true
        progress = 0.0
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playerindex?Active=&AllStar=&College=&Country=&DraftPick=&DraftRound=&DraftYear=&Height=&Historical=1&LeagueID=00&Season=2023-24&TeamID=0&Weight=")
                //        guard let validURL = URL(string: "https://stats.nba.com/stats/commonallplayers?IsOnlyCurrentSeason=0&LeagueID=00&Season=2023-24")
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
                
                for dataSets in data {
                    //                    print(dataSets["headers"])
                    //                    print(dataSets["rowSet"])
                    
                    guard let headers = dataSets["headers"] as? [Any],
                          let players = dataSets["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return
                    }
                    
                    for player in players {
                        //                        DispatchQueue.main.async {
                        // Update progress
                        receivedSize += Float(MemoryLayout.size(ofValue: player))
                        //                            print(receivedSize)
                        self.progress = Double(receivedSize / totalSize)
                        //                        print(progress)
                        //                        }
                        var i = 0
                        var p = [String : Any]()
                        
                        for header in headers {
                            //                            print("\(header) : \(player[i])")
                            p[header as! String] = player[i]
                            i += 1
                        }
                        
                        self.allPlayers.append(Player(playerID: p["PERSON_ID"] as! Int, firstName: p["PLAYER_FIRST_NAME"] as! String, lastName: p["PLAYER_LAST_NAME"] as! String, rank: 0, teamID: p["TEAM_ID"] as! Int, jersey: p["JERSEY_NUMBER"] as? String, position: p["POSITION"] as? String))
                    }
                }
            }
        } catch {
            return
        }
        
        // All data processed, task completed
//        isTaskRunning = false
//        print("done loading")
//        await getLeaders(cat: "PTS")
        //        print(allPlayers.count)
//        return
    }
    
    func getLeaders(cat: String) async {
        leaders.removeAll()
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/leagueLeaders?LeagueID=00&PerMode=PerGame&Scope=S&Season=2023-24&SeasonType=Regular%20Season&StatCategory=\(cat)")
        else { fatalError("Invalid URL")}
        
        var urlRequest = URLRequest(url: validURL)
        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
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
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["resultSet"] as? [String: Any]
                else {
                    print("This isn't working")
                    return
                }
//                print(data)
//                print(data["headers"])
//                print(data["rowSet"])
//                let headers = data["headers"]
                
                guard let headers = data["headers"] as? [Any],
                      let players = data["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                statCriteria = (headers as? [String] ?? [""])
//                print(statCriteria)
                let dni = ["PLAYER_ID", "RANK", "PLAYER", "TEAM_ID", "TEAM"]
                statCriteria.removeAll(where: { dni.contains($0) })
                
                for player in players {
                    var i = 0
                    var p = [String : Any]()
                    
                    for header in headers {
//                        print("\(header) : \(player[i])")
                        p[header as! String] = player[i]
                        i += 1
                    }
                    
//                    print(p["EFF"])
//                    print(p)
                    
                    let nameFormatter = PersonNameComponentsFormatter()
                    let name = p["PLAYER"]
                    var fname = ""
                    var lname = ""
                    
                    if let nameComps  = nameFormatter.personNameComponents(from: name as! String) {
                        fname = nameComps.givenName ?? p["PLAYER"] as! String
                        lname = nameComps.familyName ?? ""
                    }
                    
                    var newPlayer = Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, rank: p["RANK"] as? Int, teamID: p["TEAM_ID"] as! Int, gp: p["GP"] as? Double, min: p["MIN"] as? Double, fgm: p["FGM"] as? Double, fga: p["FGA"] as? Double, fg_pct: p["FG_PCT"] as? Double, fg3m: p["FG3M"] as? Double, fg3a: p["FG3A"] as? Double, fg3_pct: p["FG3_PCT"] as? Double, ftm: p["FTM"] as? Double, fta: p["FTA"] as? Double, ft_pct: p["FT_PCT"] as? Double, oreb: p["OREB"] as? Double, dreb: p["DREB"] as? Double, reb: p["REB"] as? Double, ast: p["AST"] as? Double, stl: p["STL"] as? Double, blk: p["BLK"] as? Double, tov: p["TOV"] as? Double, pts: p["PTS"] as? Double, eff: p["EFF"] as? Double)

                    if let team = Team.teamData.first(where: { $0.teamID == newPlayer.teamID }) {
                        if let player = team.roster?.first(where: { $0.playerID == newPlayer.playerID}) {
                            newPlayer.jersey = player.jersey
                            newPlayer.position = player.position
                        }
                    }
                    
                    self.leaders.append(newPlayer)
                }
            }
        } catch {
            return
        }
//        print(searchResults)
//        return searchResults
        
//        if searchResults.isEmpty {
//            soundsManager.playSound(soundFile: "no_results")
//        } else {
//            soundsManager.playSound(soundFile: "success")
//        }
        
        // All data processed, task completed
//        isTaskRunning = false
//        for leader in leaders {
//            if let pl = allPlayers.first(where: { $0.playerID == leader.playerID }) {
//                print("found in all players")
//                if pl.age == -1 {
//    //                            DispatchQueue.main.async {
//    //                                <#code#>
//    //                            }
//                    await getPlayerInfo(pID: leader.playerID)
//                }
//            } else {
//                await getPlayerInfo(pID: leader.playerID)
//            }
//        }
    }
    
    func getPlayerInfo(pID: Int) async {
//        teamRoster.removeAll()
//        var roster = [Player]()
//        var player : Player
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/commonplayerinfo?LeagueID=&PlayerID=\(pID)")
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
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["resultSets"] as? [[String: Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                print(data)
                
//                for i in data.indices {
//                    if data[i]["name"] as! String == "CommonTeamRoster" {
//                        guard let headers = data[i]["headers"] as? [Any],
//                              let players = data[i]["rowSet"] as? [[Any]]
//                        else {
//                            print("This isn't working")
//                            return
//                        }
//
////                        print(players)
//
//                        for player in players {
//                            var x = 0
//                            var p = [String : Any]()
//
//                            for header in headers {
////                                print("\(header) : \(player[x])")
//                                p[header as! String] = player[x]
//                                x += 1
//                            }
//
//                            let nameFormatter = PersonNameComponentsFormatter()
//                            let name = p["PLAYER"]
//                            var fname = ""
//                            var lname = ""
//
//                            if let nameComps  = nameFormatter.personNameComponents(from: name as! String) {
//                                fname = nameComps.givenName ?? p["PLAYER"] as! String
//                                lname = nameComps.familyName ?? ""
//                            }
////                            print(p["NUM"])
////                            roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, nickName: p["NICKNAME"] as? String, rank: 0, teamID: p["TeamID"] as! Int, jersey: p["NUM"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, birthDate: p["BIRTH_DATE"] as? String, exp: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String, age: p["AGE"] as? Int))
//                        }
//                    } else if data[i]["name"] as! String == "Coaches" {
//                        guard let headers = data[i]["headers"] as? [Any],
//                              let coaches = data[i]["rowSet"] as? [[Any]]
//                        else {
//                            print("This isn't working")
//                            return
//                        }
//
////                        print(coaches)
//
//                        for coach in coaches {
//                            var x = 0
//                            var c = [String : Any]()
//
//                            for header in headers {
////                                print("\(header) : \(coach[x])")
//                                c[header as! String] = coach[x]
//                                x += 1
//                            }
//
////                            roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: p["PLAYER"] as! String, lastName: "", nickName: p["NICKNAME"] as? String, rank: 0, teamID: p["TEAM_ID"] as! Int, number: p["JERSEY_NUMBER"] as? Int, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? Int, birthDate: p["BIRTH_DATE"] as? String, exp: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String, age: p["AGE"] as? Double))
//                        }
//                    }
//                }
            }
        } catch {
            return
        }
//        task.resume()
//        return
    }
}
