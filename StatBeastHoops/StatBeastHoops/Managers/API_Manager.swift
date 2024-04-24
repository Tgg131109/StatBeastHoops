//
//  API_Manager.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/19/23.
//

import Foundation
import SwiftUI

class APIManager : ObservableObject {
    @Published var selPlayer = 0
    @Published var p1ID = 0
    @Published var p2ID = 0
    @Published var statCompare = [StatCompare]()
    @Published var statSet = [PlayerStat]()
    @Published var searchResults = Player.popularPlayers
    @Published var p1 = Player.popularPlayers[0]
    @Published var p2 = Player.popularPlayers[1]
    @Published var seasons = [String]()
    
    let soundsManager = SoundsManager()
    
    init() {
        for y in 2002...2022 {
            let u = String(y + 1).suffix(2)
            seasons.append("\(y)-\(u)")
        }
        
        seasons.reverse()
    }
    
    @MainActor
    func getPlayers(networkManager: NetworkManager, searchStr: String) async {
//        if networkManager.notConnected {
//            print("not connected")
////            self.showAlert = true
//        } else {
//            searchResults.removeAll()
//            
//            // Validate URL.
//            guard let validURL = URL(string: "https://www.balldontlie.io/api/v1/players?per_page=100&search=\(searchStr)")
//            else { fatalError("Invalid URL")}
//            
//            let urlRequest = URLRequest(url: validURL)
//            
//            do {
//                let (validData, response) = try await URLSession.shared.data(for: urlRequest)
//                
//                guard let httpResponse = response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200 // 200 = OK
//                else {
//                    DispatchQueue.main.async {
//                        // Present alert on main thread if there is an error with the URL.
//                    }
//                    
//                    print("JSON object creation failed.")
//                    return
//                }
//                
//                // Create json Object from downloaded data above and cast as [String: Any].
//                if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
//                    guard let data = jsonObj["data"] as? [[String: Any]]
//                    else {
//                        print("This isn't working")
//                        return
//                    }
////                    print(data)
//                    for player in data {
//                        // Step through outer level data to get to relevant post data.
//                        guard let playerID = player["id"] as? Int,
//                              let firstName = player["first_name"] as? String,
//                              let lastName = player["last_name"] as? String,
//                              let position = player["position"] as? String,
//                              let playerTeam = player["team"] as? [String: Any],
//                              let teamID = playerTeam["id"] as? Int
//                        else {
//                            print("There was an error with this player's data")
//                            continue
//                        }
//
//                        // Since height data is not always provided and is an int,
//                        // set their optional values outside of guard statement
//                        // to prevent player from being ommitted from search results.
//                        let heightFt = player["height_feet"] as? Int
//                        let heightIn = player["height_inches"] as? Int
//
//                        self.searchResults.append(Player(playerID: playerID, firstName: firstName, lastName: lastName, rank: heightFt, teamID: heightIn, number: position, position: teamID))
//                    }
//                }
//            } catch {
//                return
//            }
//            
//            if searchResults.isEmpty {
//                soundsManager.playSound(soundFile: "no_results")
//            } else {
//                soundsManager.playSound(soundFile: "success")
//            }
//        }
    }

    @MainActor
    func getStats(networkManager: NetworkManager, season: String = "2022", pID: Int = -1) async {
//        var arr = [Int]()
//        var sc = [StatCompare]()
//        var ps = [PlayerStat]()
//        var statDict : [Int : [String]] = [:]
//        var count = 1
//        
//        let stats = ["Games Played", "Minutes", "Points", "FG Made", "FG Attempted", "FG %", "3pt FG Made", "3pt FG Attempted", "3pt FG %", "FT Made", "FT Attempted", "FT %", "O Reb", "D Reb", "Rebounds", "Assists", "Steals", "Blocks", "Turnovers", "Fouls"]
//        
//        if pID == -1 {
//            arr = [p1ID, p2ID]
//        } else {
//            arr = [pID]
//        }
//        
//        if networkManager.notConnected {
//            print("not connected")
////            self.showAlert = true
//        } else {
//            if arr.count > 1 {
//                soundsManager.playSound(soundFile: "compare")
//                
//                for n in 0...19 {
//                    statDict[n] = [stats[n], "-", "-"]
//                }
//            } else {
//                statSet.removeAll()
//            }
//            
//            for i in arr {
//                
//                // Validate URL.
//                guard let validURL = URL(string: "https://www.balldontlie.io/api/v1/season_averages?season=\(season)&player_ids[]=\(i)")
//                else { fatalError("Invalid URL")}
//                
//                let urlRequest = URLRequest(url: validURL)
//                
//                do {
//                    let (validData, response) = try await URLSession.shared.data(for: urlRequest)
//                    
//                    guard let httpResponse = response as? HTTPURLResponse,
//                          httpResponse.statusCode == 200 // 200 = OK
//                    else {
//                        DispatchQueue.main.async {
//                            // Present alert on main thread if there is an error with the URL.
//                        }
//                        
//                        print("JSON object creation failed.")
//                        return
//                    }
//                    
//                    // Create json Object from downloaded data above and cast as [String: Any].
//                    if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
//                        guard let data = jsonObj["data"] as? [[String: Any]]
//                        else {
//                            print("This isn't working")
//                            return
//                        }
//                        
//                        for playerStat in data {
//                            for s in playerStat {
//                                // Step through outer level data to get to relevant stat data.
//                                var id = 0
//                                var value = s.value
//                                
//                                switch s.key {
//                                case "games_played":
//                                    id = 1
//                                case "min":
//                                    id = 2
//                                case "fgm":
//                                    id = 4
//                                case "fga":
//                                    id = 5
//                                case "fg3m":
//                                    id = 7
//                                case "fg3a":
//                                    id = 8
//                                case "ftm":
//                                    id = 10
//                                case "fta":
//                                    id = 11
//                                case "oreb":
//                                    id = 13
//                                case "dreb":
//                                    id = 14
//                                case "reb":
//                                    id = 15
//                                case "ast":
//                                    id = 16
//                                case "stl":
//                                    id = 17
//                                case "blk":
//                                    id = 18
//                                case "turnover":
//                                    id = 19
//                                case "pf":
//                                    id = 20
//                                case "pts":
//                                    id = 3
//                                case "fg_pct":
//                                    id = 6
//                                case "fg3_pct":
//                                    id = 9
//                                case "ft_pct":
//                                    id = 12
//                                default:
//                                    continue
//                                }
//                                
//                                if let v = value as? Double {
//                                    value = v
//                                    
//                                    if s.key.suffix(3) == "pct" {
//                                        value = "\(String(format: "%.1f", v * 100)) %"
//                                    }
//                                }
//                                
//                                if arr.count > 1 {
//                                    // add stat set to the stat dictionary.
//                                    // create dictionary item if one doesn't exist.
//                                    statDict[id - 1]?[count] = "\(value)"
//                                } else {
//                                    ps.append(PlayerStat(id: id, stat: stats[id - 1], value: "\(value)"))
//                                }
//                            }
//                        }
//                        
//                        if arr.count > 1 {
//                            if count == 2 {
//                                for statID in statDict.keys {
//                                    if let v : [String] = statDict[statID] {
//                                        sc.append(StatCompare(id: statID, stat: v[0], value1: v[1], value2: v[2]))
//                                    }
//                                }
//                                
//                                self.statCompare = sc.sorted(by: { $1.id > $0.id })
//                            } else {
//                                count += 1
//                            }
//                        } else {
//                            if ps.isEmpty {
//                                soundsManager.playSound(soundFile: "no_results")
//                            } else {
//                                soundsManager.playSound(soundFile: "success")
//                                
//                                ps = ps.sorted(by: { $1.id > $0.id })
//                                self.statSet = ps
//                            }
//                        }
//                    }
//                } catch {
//                    return
//                }
//            }
//        }
    }

    @MainActor
    func getTeamData(networkManager: NetworkManager, season : String, tID: Int) async -> [TeamGame] {
        var teamData = [TeamGame]()
//        
//        if networkManager.notConnected {
//            print("not connected")
////            self.showAlert = true
//        } else {
//            // Validate URL.
//            guard let validURL = URL(string: "https://www.balldontlie.io/api/v1/games?per_page=100&seasons[]=\(season)&team_ids[]=\(tID)")
//            else { fatalError("Invalid URL")}
//            
//            let urlRequest = URLRequest(url: validURL)
//            
//            do {
//                let (validData, response) = try await URLSession.shared.data(for: urlRequest)
//                
//                guard let httpResponse = response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200 // 200 = OK
//                else {
//                    DispatchQueue.main.async {
//                        // Present alert on main thread if there is an error with the URL.
//                    }
//                    
//                    print("JSON object creation failed.")
//                    return teamData
//                }
//                
//                // Create json Object from downloaded data above and cast as [String: Any].
//                if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
//                    guard let data = jsonObj["data"] as? [[String: Any]]
//                    else {
//                        print("This isn't working")
//                        return teamData
//                    }
//                    
//                    for gameStat in data {
//                        // Step through outer level data to get to relevant game data.
//                        guard let gameID = gameStat["id"] as? Int,
//                              let htScore = gameStat["home_team_score"] as? Int,
//                              let vtScore = gameStat["visitor_team_score"] as? Int,
//                              let postseason = gameStat["postseason"] as? Bool,
//                              let homeTeam = gameStat["home_team"] as? [String: Any],
//                              let homeTeamID = homeTeam["id"] as? Int,
//                              let visitorTeam = gameStat["visitor_team"] as? [String: Any],
//                              let vistorTeamID = visitorTeam["id"] as? Int
//                        else {
//                            print("There was an error with this player's data")
//                            continue
//                        }
//                        
//                        teamData.append(TeamGame(gameID: gameID, sourceTeamID: tID, homeTeamID: homeTeamID, homeTeamScore: htScore, awayTeamID: vistorTeamID, awayTeamScore: vtScore, isPostseason: postseason))
//                    }
//                    
//                    if teamData.isEmpty {
//                        soundsManager.playSound(soundFile: "no_results")
//                    } else {
//                        soundsManager.playSound(soundFile: "success")
//                    }
//                }
//            } catch {
//                return teamData
//            }
//        }
        
        return teamData
    }
}
