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
    @Published var historicalPlayers = [Player]()
    @Published var inactivePlayers = [Player]()
    @Published var leaders = [Player]()
    @Published var playerHeadshots = [PlayerHeadshot]()
    @Published var playerStats = [PlayerStats]()
    @Published var playerGameStats = [PlayerGameStats]()
//    @Published var isTaskRunning = true
    
    
    
    @Published var searchResults = [Player]()
    @Published var statCriteria = [String]()
    @Published var statCompare = [StatCompare]()
    @Published var gameStatCompare = [StatSeriesCompare]()
//    @Published var gameStats = [StatSeriesAll]()
    @Published var teams = [Team]()
    @Published var seasons = [String]()
    @Published var teamRoster = [Player]()
    
    @Published var progress: Double = 0.0
    
    // Stat Compare
    @Published var sp : Player? = nil
    @Published var p1 : Player? = nil
    @Published var p2 : Player? = nil
    
    @Published var currentDetent = PresentationDetent.height(400)
    @Published var needsOverlay = true
    @Published var showComparePage = false
    @Published var showSettingsPage = false
    
//    @Published var playerStats = [PlayerStats]()
    init() {
        for y in 2002...2024 {
            let u = String(y + 1).suffix(2)
            seasons.append("\(y)-\(u)")
        }
        
        seasons.reverse()
    }
    
    func getAllPlayers() async {
        // playerindex endpoint (set Active=1 for only current players)
        // This is just player info, no stats.
        allPlayers.removeAll()
//        progress = 0.0
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playerindex?Active=1&AllStar=&College=&Country=&DraftPick=&DraftRound=&DraftYear=&Height=&Historical=1&LeagueID=00&Season=2023-24&TeamID=0&Weight=")
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
                    self.progress = Double(receivedSize / totalSize)
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
                
                guard let headers = data["headers"] as? [Any],
                      let players = data["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                statCriteria = (headers as? [String] ?? [""])
                let dni = ["PLAYER_ID", "RANK", "PLAYER", "TEAM_ID", "TEAM"]
                statCriteria.removeAll(where: { dni.contains($0) })
                
                for player in players {
                    var i = 0
                    var p = [String : Any]()
                    
                    for header in headers {
                        p[header as! String] = player[i]
                        i += 1
                    }
                    
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
                        if let player = team.roster?.first(where: { $0.playerID == newPlayer.playerID }) {
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
    }
    
    func getPlayerStats(pID: Int) async {
        // playerprofilev2 endpoint
        // Contains career and season info including highs, pre/post season, and college.
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playerprofilev2?LeagueID=&PerMode=Totals&PlayerID=\(pID)")
        else { fatalError("Invalid URL")}
        
        var urlRequest = URLRequest(url: validURL)
        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")

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
                
                // Available data sets (15)
                // SeasonTotalsRegularSeason
                // CareerTotalsRegularSeason
                // SeasonTotalsPostSeason
                // CareerTotalsPostSeason
                // SeasonTotalsAllStarSeason
                // CareerTotalsAllStarSeason
                // SeasonTotalsCollegeSeason
                // CareerTotalsCollegeSeason
                // SeasonTotalsPreseason
                // CareerTotalsPreseason
                // SeasonRankingsRegularSeason
                // SeasonRankingsPostSeason
                // SeasonHighs
                // CareerHighs
                // NextGame
                
                for i in data.indices {
                    if data[i]["name"] as! String == "SeasonTotalsRegularSeason" {
                        guard let headers = data[i]["headers"] as? [Any],
                              let statData = data[i]["rowSet"] as? [[Any]]
                        else {
                            print("This isn't working")
                            return
                        }
                        
                        var ps = PlayerStats(playerID: pID, seasonStats: [:])
                        
                        for ss in statData {
                            var x = 0
                            var p = [String : Any]()
                            
                            for header in headers {
                                print("\(header) : \(ss[x])")
                                p[header as! String] = ss[x]
                                x += 1
                            }
                            
                            let seasonStats = SeasonStats(gp: p["GP"] as? Double, gs: p["GS"] as? Double, min: p["MIN"] as? Double, fgm: p["FGM"] as? Double, fga: p["FGA"] as? Double, fg_pct: p["FG_PCT"] as? Double, fg3m: p["FG3M"] as? Double, fg3a: p["FG3A"] as? Double, fg3_pct: p["FG3_PCT"] as? Double, ftm: p["FTM"] as? Double, fta: p["FTA"] as? Double, ft_pct: p["FT_PCT"] as? Double, oreb: p["OREB"] as? Double, dreb: p["DREB"] as? Double, reb: p["REB"] as? Double, ast: p["AST"] as? Double, stl: p["STL"] as? Double, blk: p["BLK"] as? Double, tov: p["TOV"] as? Double, pf: p["PF"] as? Double, pts: p["PTS"] as? Double)
                            
                            ps.seasonStats[p["SEASON_ID"] as! String] = seasonStats
                        }
                        
                        playerStats.append(ps)
                    }
                }
            }
        } catch {
            return
        }
    }
    
    func getPlayerGameStats(pID: Int) async {
        // playergamelogs endpoint
        // Provides the same data as the playergamelog (no s) endpoint with rankings
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playergamelogs?DateFrom=&DateTo=&GameSegment=&LastNGames=&LeagueID=&Location=&MeasureType=&Month=&OppTeamID=&Outcome=&PORound=&PerMode=&Period=&PlayerID=\(pID)&Season=2023-24&SeasonSegment=&SeasonType=&ShotClockRange=&TeamID=&VsConference=&VsDivision=")
        else { fatalError("Invalid URL")}
        
        var urlRequest = URLRequest(url: validURL)
        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")

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
                
                guard let headers = data[0]["headers"] as? [Any],
                      let games = data[0]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                print(headers)
                print(games.count)
//                for i in data.indices {
//                    if data[i]["name"] as! String == "SeasonTotalsRegularSeason" {
//                        guard let headers = data[i]["headers"] as? [Any],
//                              let gameData = data[i]["rowSet"] as? [[Any]]
//                        else {
//                            print("This isn't working")
//                            return
//                        }
                        
                var pgs = PlayerGameStats(playerID: pID, season: "2023-24", gameStats: [])
                        
                        for game in games {
                            var x = 0
                            var p = [String : Any]()
                            
                            for header in headers {
                                print("\(header) : \(game[x])")
                                p[header as! String] = game[x]
                                x += 1
                            }
                            
                            let gameStats = GameStats(gameID: p["GAME_ID"] as! String, gameDate: p["GAME_DATE"] as! String, matchup: p["MATCHUP"] as! String, wl: p["WL"] as! String, min: p["MIN"] as? Double, fgm: p["FGM"] as? Double, fga: p["FGA"] as? Double, fg_pct: p["FG_PCT"] as? Double, fg3m: p["FG3M"] as? Double, fg3a: p["FG3A"] as? Double, fg3_pct: p["FG3_PCT"] as? Double, ftm: p["FTM"] as? Double, fta: p["FTA"] as? Double, ft_pct: p["FT_PCT"] as? Double, oreb: p["OREB"] as? Double, dreb: p["DREB"] as? Double, reb: p["REB"] as? Double, ast: p["AST"] as? Double, stl: p["STL"] as? Double, blk: p["BLK"] as? Double, tov: p["TOV"] as? Double, pf: p["PF"] as? Double, pts: p["PTS"] as? Double)
                            
                            pgs.gameStats.append(gameStats)
                        }
                        
                // We need to check if these season already exist and remove them if so.
                // We might even do this at the beginning to prevent the call if the data already exists.
                // We'll have to keep ongoing games in mind if we go with the second approach
                        playerGameStats.append(pgs)
//                    }
//                }
            }
        } catch {
            return
        }
    }
    
    func testFunc(pID: Int) async {
        // playergamelogs endpoint
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playergamelog?DateFrom=&DateTo=&LeagueID=&PlayerID=\(pID)&Season=2023-24&SeasonType=Regular+Season")
        else { fatalError("Invalid URL")}
        
        var urlRequest = URLRequest(url: validURL)
        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")

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
                
                guard let headers = data[0]["headers"] as? [Any],
                      let games = data[0]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                print(headers)
                print(games.count)
//                for i in data.indices {
//                    if data[i]["name"] as! String == "SeasonTotalsRegularSeason" {
//                        guard let headers = data[i]["headers"] as? [Any],
//                              let gameData = data[i]["rowSet"] as? [[Any]]
//                        else {
//                            print("This isn't working")
//                            return
//                        }
                        
//                        var ps = PlayerStats(playerID: pID, seasonStats: [:])
//
//                        for ss in statData {
//                            var x = 0
//                            var p = [String : Any]()
//
//                            for header in headers {
//                                print("\(header) : \(ss[x])")
//                                p[header as! String] = ss[x]
//                                x += 1
//                            }
//
//                            let seasonStats = SeasonStats(gp: p["GP"] as? Double, gs: p["GS"] as? Double, min: p["MIN"] as? Double, fgm: p["FGM"] as? Double, fga: p["FGA"] as? Double, fg_pct: p["FG_PCT"] as? Double, fg3m: p["FG3M"] as? Double, fg3a: p["FG3A"] as? Double, fg3_pct: p["FG3_PCT"] as? Double, ftm: p["FTM"] as? Double, fta: p["FTA"] as? Double, ft_pct: p["FT_PCT"] as? Double, oreb: p["OREB"] as? Double, dreb: p["DREB"] as? Double, reb: p["REB"] as? Double, ast: p["AST"] as? Double, stl: p["STL"] as? Double, blk: p["BLK"] as? Double, tov: p["TOV"] as? Double, pf: p["PF"] as? Double, pts: p["PTS"] as? Double)
//
//                            ps.seasonStats[p["SEASON_ID"] as! String] = seasonStats
//                        }
//
//                        playerStats.append(ps)
//                    }
//                }
            }
        } catch {
            return
        }
    }
    
    func getGameStats(pID: Int) async -> [StatSeriesAll] {
        var gameStats : [StatSeriesAll] = []
        // Validate URL.
//        for pID in pIDs {
            guard let validURL = URL(string: "https://stats.nba.com/stats/playergamelogs?DateFrom=&DateTo=&GameSegment=&LastNGames=&LeagueID=&Location=&MeasureType=&Month=&OppTeamID=&Outcome=&PORound=&PerMode=&Period=&PlayerID=\(pID)&Season=2023-24&SeasonSegment=&SeasonType=&ShotClockRange=&TeamID=&VsConference=&VsDivision=")
            else { fatalError("Invalid URL")}
            
            var urlRequest = URLRequest(url: validURL)
            urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
            
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
                    
                    guard let headers = data[0]["headers"] as? [Any],
                          let games = data[0]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return []
                    }
                    
                    //                print(headers)
                    //                print(games.count)
                    
                    //                statSet = ["categories" : headers]
                    
                    // This is where shit gets wierd
                    // Ultimately we need an array of stats for the season grouped by stat type.
                    // We also need to separate out game data info (vs, location, date, etc.)
                    // Should look like [category : [stat]].
                    // Stat object should consist of id : Int, value : Any.
                    
                    // Create an array of PlayerStatSeries objects to contain each set of stats by category.
                    var ss = [PlayerStatSeries]()
                    
                    // Start by grabbing each header (category).
                    for x in headers.indices {
                        // Create an array of Stat objects to contain each game stat.
                        var d = [Stat]()
                        
                        // Next grab category stats for each game, create a Stat object, and add to Stat array.
                        for i in games.indices {
                            //                        let v = games[i]
                            //                        print(v[x])
                            d.append(Stat(id: i, value: "\(games[i][x])"))
                        }
                        
                        // Create a new PlayerStatSeries object to contain each category's stats and add to PlayerStatSeries array.
                        ss.append(PlayerStatSeries(category: "\(headers[x])", statData: d))
                    }
                    
                    gameStats.append(StatSeriesAll(id: "\(pID)", statData: ss))
                }
            } catch {
                return []
            }
//        }
        return gameStats
//        getChartData(criteria: criteria, pIDs: pIDs)
    }
    
    func getAllPlayerStats() async {
        // debating between a couple of endpoints here...
        // playercareerstats (all stats including college, pre/post season)
        // leaguedashplayerbiostats (has draft and country info)
        // leaguedashplayerstats (returns player stats for entire league for a given season with rankings)
        // commonplayerinfo (all player info and headline stats displayed on a nba.com player page. contains everthing from playerindex endpoint + headline stats)
        // playerprofilev2 (has career/season highs)
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/leaguedashplayerstats?College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PORound=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season=2023-24&SeasonSegment=&SeasonType=Regular+Season&ShotClockRange=&StarterBench=&TeamID=&TwoWay=&VsConference=&VsDivision=&Weight=")
        else { fatalError("Invalid URL")}
        
        var urlRequest = URLRequest(url: validURL)
        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")

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
                
                guard let headers = data[0]["headers"] as? [Any],
                      let players = data[0]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                print(headers)

                for player in players {
                    var x = 0
                    var p = [String : Any]()
                    
                    for header in headers {
//                        print("\(header) : \(player[x])")
                        p[header as! String] = player[x]
                        x += 1
                    }
                    
//                    let nameFormatter = PersonNameComponentsFormatter()
//                    let name = p["PLAYER"]
//                    var fname = ""
//                    var lname = ""
//                    
//                    if let nameComps  = nameFormatter.personNameComponents(from: name as! String) {
//                        fname = nameComps.givenName ?? p["PLAYER"] as! String
//                        lname = nameComps.familyName ?? ""
//                    }
                    
//                    print(p["NUM"])
                    
                    // Create PlayerStat object for each player
                    
                    
                    
                    let tID = p["TEAM_ID"] as! Int
                    let pID = p["PLAYER_ID"] as! Int
                    
                    if let x = Team.teamData.firstIndex(where: { $0.teamID == tID }) {
                        if let i = Team.teamData[x].roster?.firstIndex(where: { $0.playerID == pID }) {
                            Team.teamData[x].roster?[i].nickName = p["NICKNAME"] as? String
                        }
                    } else {
                        print("player not found on team - \(p["PLAYER_NAME"])")
                    }
                    
                    
                    
                    
////                            roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, nickName: p["NICKNAME"] as? String, rank: 0, teamID: p["TeamID"] as! Int, jersey: p["NUM"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, birthDate: p["BIRTH_DATE"] as? String, exp: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String, age: p["AGE"] as? Int))
//
                }
            }
        } catch {
            return
        }
//        task.resume()
//        return
    }
    
//    func getPlayerHeadshot(pID: Int, tID: Int) -> Image {
//        let team = Team.teamData.first(where: { $0.teamID == tID })
//        var hs =
//        if let pic = playerHeadshots.first(where: { $0.playerID == pID })?.pic {
//            return pic
//        } else {
//            // Download image
////            var headshotView: some View {
//                AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(pID).png")) { phase in
//                    switch phase {
//                    case .empty:
//                        Image(uiImage: team?.logo).resizable().aspectRatio(contentMode: .fill)
//                    case .success(let image):
//                        let _ = DispatchQueue.main.async {
//                            playerHeadshots.append(PlayerHeadshot(playerID: pID, pic: image))
//                        }
//                        
//                        image.resizable().scaledToFit()
//                    case .failure:
//                        Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill)
//                    @unknown default:
//                        Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill)
//                    }
//                }
//                .frame(width: 80, height: 60, alignment: .bottom)
//                .padding(.trailing, -20)
////            }
//        }
//    }
}
