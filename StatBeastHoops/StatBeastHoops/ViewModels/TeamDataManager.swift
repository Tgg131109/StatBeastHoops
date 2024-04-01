//
//  TeamDataManager.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/31/24.
//

import Foundation
import SwiftUI

@MainActor
class TeamDataManager : ObservableObject {
    @Published var teams = [Team]()
    @Published var teamPlayers = [Int : [Player]]()
    @Published var teamCoaches = [Int : [Player]]()
    
    func getTeamStandings() async {
        teams = Team.teamData
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/leaguestandings?LeagueID=00&Season=2023-24&SeasonType=Regular+Season&SeasonYear=")
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
                
                guard let headers = data[0]["headers"] as? [String],
                      let standings = data[0]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
//                print(standings)
//                let idI = headers.firstIndex(of: "TeamID")
                guard let idI = headers.firstIndex(of: "TeamID"),
                      let tnI = headers.firstIndex(of: "TeamName"),
                      let wI = headers.firstIndex(of: "WINS"),
                      let lI = headers.firstIndex(of: "LOSSES"),
                      let rI = headers.firstIndex(of: "Record"),
                      let drI = headers.firstIndex(of: "DivisionRank"),
                      let lrI = headers.firstIndex(of: "LeagueRank")
                else {
                    print("There was an error getting team data")
                    return
                }
                
                for t in standings {
                    let tID = t[idI] as! Int
                    
                    guard let x = teams.firstIndex(where: { $0.teamID == tID})
                    else {
                        print("Couldn't find team")
                        return
                    }

                    teams[x].wins = t[wI] as? Int
                    teams[x].loss = t[lI] as? Int
                    teams[x].divRank = t[drI] as? Int
                    teams[x].leagueRank = t[lrI] as? Int
                }
            }
        } catch {
            return
        }
//        print(games.count)
//        return teams
    }
    
    func getTeamRosters(teamID: Int) async -> [Player] {
//        teamRoster.removeAll()
//        var teamIDs = [String]()
//        
//        for team in teams {
//            teamIDs.append("\(team.teamID)")
//        }
//        
//        let teams = Teams(teamIDs: teamIDs)
//        
//        do {
//            for try await teamID in teams {
//                print(teamID.count)
//            }
//        } catch {
//            print(error)
//        }
        
        
        
        
//        await ForEach(teams, id: \.teamID) { t in
////            teamIDs.append(t.teamID)
//            
//        }
        

//        
//        for await id in teamIDs {
//            
//        }
//        for await team in teams {
//        print("here")
        
            var roster = [Player]()
//        var team = Team.teamData.first(where: { $0.teamID == teamID })
        
            // Validate URL.
            guard let validURL = URL(string: "https://stats.nba.com/stats/commonteamroster?LeagueID=&Season=2023-24&TeamID=\(teamID)")
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
                    return []
                }
                
                // Create json Object from downloaded data above and cast as [String: Any].
                if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                    guard let data = jsonObj["resultSets"] as? [[String: Any]]
                    else {
                        print("This isn't working")
                        return []
                    }
                    
                    for i in data.indices {
                        if data[i]["name"] as! String == "CommonTeamRoster" {
                            guard let headers = data[i]["headers"] as? [Any],
                                  let players = data[i]["rowSet"] as? [[Any]]
                            else {
                                print("This isn't working")
                                return []
                            }
                            
                            //                        print(players)
                            
                            for player in players {
                                var x = 0
                                var p = [String : Any]()
                                
                                for header in headers {
                                    //                                print("\(header) : \(player[x])")
                                    p[header as! String] = player[x]
                                    x += 1
                                }
                                
                                let nameFormatter = PersonNameComponentsFormatter()
                                let name = p["PLAYER"]
                                var fname = ""
                                var lname = ""
                                
                                if let nameComps  = nameFormatter.personNameComponents(from: name as! String) {
                                    fname = nameComps.givenName ?? p["PLAYER"] as! String
                                    lname = nameComps.familyName ?? ""
                                }
                                //                            print(p["NUM"])
                                roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, nickName: p["NICKNAME"] as? String, rank: 0, teamID: p["TeamID"] as! Int, jersey: p["NUM"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, birthDate: p["BIRTH_DATE"] as? String, exp: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String, age: p["AGE"] as? Int))
                            }
                            
                            teamPlayers[teamID] = roster

                            if let i = Team.teamData.firstIndex(where: { $0.teamID == teamID }) {
                                Team.teamData[i].roster = roster
                            }
                        } else if data[i]["name"] as! String == "Coaches" {
                            guard let headers = data[i]["headers"] as? [Any],
                                  let coaches = data[i]["rowSet"] as? [[Any]]
                            else {
                                print("This isn't working")
                                return []
                            }
                            
                            //                        print(coaches)
                            
                            for coach in coaches {
                                var x = 0
                                var c = [String : Any]()
                                
                                for header in headers {
                                    //                                print("\(header) : \(coach[x])")
                                    c[header as! String] = coach[x]
                                    x += 1
                                }
                                
                                //                            roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: p["PLAYER"] as! String, lastName: "", nickName: p["NICKNAME"] as? String, rank: 0, teamID: p["TEAM_ID"] as! Int, number: p["JERSEY_NUMBER"] as? Int, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? Int, birthDate: p["BIRTH_DATE"] as? String, exp: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String, age: p["AGE"] as? Double))
                            }
                        }
                    }
                }
            } catch {
                return []
            }
            //        task.resume()
        return roster
//        }
    }
    
    func getTodaysGames() async -> [Game] {
        var games = [Game]()
        
        // Validate URL.
        guard let validURL = URL(string: "https://cdn.nba.com/static/json/liveData/scoreboard/todaysScoreboard_00.json")
        else { fatalError("Invalid URL")}
        
        let urlRequest = URLRequest(url: validURL)
        //        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
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
                return []
            }
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["scoreboard"] as? [String: Any]
                else {
                    print("This isn't working")
                    return []
                }
                
                guard let gameData = data["games"] as? [Any]
                else {
                    print("This isn't working")
                    return []
                }
                
                for game in gameData {
                    if let g = game as? [String : Any] {
                        guard let ht = g["homeTeam"] as? [String : Any],
                              let at = g["awayTeam"] as? [String : Any]
                        else {
                            print("There was an error getting team data")
                            continue
                        }
                        
                        guard let id = g["gameId"] as? String,
                              let status = g["gameStatusText"] as? String,
                              let clock = g["gameClock"] as? String,
                              let time = g["gameTimeUTC"] as? String,
                              let htID = ht["teamId"] as? Int,
                              let hScore = ht["score"] as? Int,
                              let atID = at["teamId"] as? Int,
                              let aScore = at["score"] as? Int
                        else {
                            print("There was an error getting team data")
                            continue
                        }
                        
                        games.append(Game(id: id, status: status, clock: clock, time: time, homeTeamID: htID, awayTeamID: atID, homeTeamScore: hScore, awayTeamScore: aScore))
                    } else {
                        print("game data error")
                    }
                }
                
            }
        } catch {
            return []
        }
//        print(games.count)
        return games
    }
}
