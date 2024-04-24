//
//  DataManager.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/5/24.
//

import Foundation
import SwiftUI

class DataManager : ObservableObject {
    @Published var allPlayers = [Player]()
    @Published var searchResults = [Player]()
    @Published var statCriteria = [String]()
    @Published var statCompare = [StatCompare]()
    @Published var gameStatCompare = [StatSeriesCompare]()
    @Published var gameStats = [StatSeriesAll]()
    @Published var teams = [Team]()
    @Published var seasons = [String]()
    @Published var teamRoster = [Player]()
    @Published var isTaskRunning = false
    @Published var progress: Double = 0.0
    @Published var sp : Player? = nil
    @Published var p1 : Player? = nil
    @Published var p2 : Player? = nil
    @Published var currentDetent = PresentationDetent.height(400)
    @Published var showComparePage = false
    @Published var showSettingsPage = false
    @Published var playerHeadshots = [PlayerHeadshot]()
    @Published var playerStats = [PlayerStats]()
    
    let soundsManager = SoundsManager()
    
    init() {
        for y in 2002...2023 {
            let u = String(y + 1).suffix(2)
            seasons.append("\(y)-\(u)")
        }
        
        seasons.reverse()
    }
    
    // Moved to HomeViewModel
    @MainActor
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
    
    @MainActor
    func getLeaders(cat: String) async -> [Player] {
        searchResults.removeAll()
        
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
                return []
            }
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["resultSet"] as? [String: Any]
                else {
                    print("This isn't working")
                    return []
                }
//                print(data)
//                print(data["headers"])
//                print(data["rowSet"])
//                let headers = data["headers"]
                
                guard let headers = data["headers"] as? [Any],
                      let players = data["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return []
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
                    
                    // Step through outer level data to get to relevant post data.
//                    guard let playerID = player["id"] as? Int,
//                          let firstName = player["first_name"] as? String,
//                          let lastName = player["last_name"] as? String,
//                          let position = player["position"] as? String,
//                          let playerTeam = player["team"] as? [String: Any],
//                          let teamID = playerTeam["id"] as? Int
//                    else {
//                        print("There was an error with this player's data")
//                        continue
//                    }
//
//                    // Since height data is not always provided and is an int,
//                    // set their optional values outside of guard statement
//                    // to prevent player from being ommitted from search results.
//                    let heightFt = player["height_feet"] as? Int
//                    let heightIn = player["height_inches"] as? Int
                    
                    let nameFormatter = PersonNameComponentsFormatter()
                    let name = p["PLAYER"]
                    var fname = ""
                    var lname = ""
                    
                    if let nameComps  = nameFormatter.personNameComponents(from: name as! String) {
                        fname = nameComps.givenName ?? p["PLAYER"] as! String
                        lname = nameComps.familyName ?? ""
                    }
                    
                    let newPlayer = Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, rank: p["RANK"] as? Int, teamID: p["TEAM_ID"] as! Int, gp: p["GP"] as? Double, min: p["MIN"] as? Double, fgm: p["FGM"] as? Double, fga: p["FGA"] as? Double, fg_pct: p["FG_PCT"] as? Double, fg3m: p["FG3M"] as? Double, fg3a: p["FG3A"] as? Double, fg3_pct: p["FG3_PCT"] as? Double, ftm: p["FTM"] as? Double, fta: p["FTA"] as? Double, ft_pct: p["FT_PCT"] as? Double, oreb: p["OREB"] as? Double, dreb: p["DREB"] as? Double, reb: p["REB"] as? Double, ast: p["AST"] as? Double, stl: p["STL"] as? Double, blk: p["BLK"] as? Double, tov: p["TOV"] as? Double, pts: p["PTS"] as? Double, eff: p["EFF"] as? Double)
                    
                    self.searchResults.append(newPlayer)
                    
                    if let pl = allPlayers.first(where: { $0.playerID == newPlayer.playerID }) {
                        print("found in all players")
                        if pl.age == -1 {
//                            DispatchQueue.main.async {
//                                <#code#>
//                            }
                            await getPlayerInfo(pID: newPlayer.playerID)
                        }
                    } else {
                        await getPlayerInfo(pID: newPlayer.playerID)
                    }
                }
            }
        } catch {
            return []
        }
//        print(searchResults)
        return searchResults
        
//        if searchResults.isEmpty {
//            soundsManager.playSound(soundFile: "no_results")
//        } else {
//            soundsManager.playSound(soundFile: "success")
//        }
//        if let url = URL(string: "https://stats.nba.com/stats/leagueLeaders?LeagueID=00&PerMode=PerGame&Scope=S&Season=2023-24&SeasonType=Regular%20Season&StatCategory=PTS") {
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
////            request.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
////            request.setValue("text/plain",forHTTPHeaderField: "Accept")
////            request.setValue("e11f18b4-5015-45ad-8276-18269a7bf047", forHTTPHeaderField: "Authorization")
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                guard error == nil else {
//                    print(error!)
//                    return
//                }
//                guard let data = data else {
//                    print("Data is empty")
//                    return
//                }
//                
//                let result = String(data: data, encoding: .utf8)
//                print("result: \(result)")
//                
//            }
//            task.resume()
//        }
    }
    
    @MainActor
    func getAllPlayers() async -> [Player] {
        allPlayers.removeAll()
        isTaskRunning = true
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
                return []
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
                    return []
                }

                for dataSets in data {
//                    print(dataSets["headers"])
//                    print(dataSets["rowSet"])

                    guard let headers = dataSets["headers"] as? [Any],
                          let players = dataSets["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return []
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
            return []
        }
        
        // All data processed, task completed
        isTaskRunning = false
        
//        print(allPlayers.count)
        return allPlayers
    }
    
    @MainActor
    func compareStats(p1ID: String, p2ID: String, criteria: String) async {
        statCompare.removeAll()
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playervsplayer?DateFrom=&DateTo=&GameSegment=&LastNGames=0&LeagueID=&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerID=\(p1ID)&PlusMinus=N&Rank=N&Season=2023-24&SeasonSegment=&SeasonType=Regular+Season&VsConference=&VsDivision=&VsPlayerID=\(p2ID)")
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
                
                if data[0]["name"] as! String == "Overall" {
                    guard let headers = data[0]["headers"] as? [Any],
                          let statData = data[0]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return
                    }
                    
//                    print(headers)
//                    print(statData[0])
                    
                    var sc = [StatCompare]()
                    
                    for i in headers.indices  {
                        var v1 = "\(statData[0][i])"
                        var v2 = "\(statData[1][i])"
                        
                        if (headers[i] as! String).contains("PCT") {
                            for p in 0...1 {
                                if let d = statData[p][i] as? Double {
//                                    print("\(d * 100) %")
                                    if p == 0 {
                                        v1 = "\(String(format: "%.1f", d * 100)) %"
                                    } else {
                                        v2 = "\(String(format: "%.1f", d * 100)) %"
                                    }
                                }
                            }
                        }
                        
                        if headers[i] as! String == "MIN" {
                            for p in 0...1 {
                                if let d = statData[p][i] as? Double {
//                                    print(d.rounded())
//                                    print(String(format: "%.1f", d))
                                    if p == 0 {
                                        v1 = String(format: "%.1f", d)
                                    } else {
                                        v2 = String(format: "%.1f", d)
                                    }
                                }
                            }
                        }

                        sc.append(StatCompare(id: i, stat: headers[i] as! String, value1: v1, value2: v2))
                    }
                    
                    sc.removeAll(where: {$0.stat == "GROUP_SET" || $0.stat == "GROUP_VALUE" || $0.stat == "PLAYER_ID" || $0.stat == "PLAYER_NAME"})
                    
                    self.statCompare = sc.sorted(by: { $1.id > $0.id })
                }
            }
        } catch {
            return
        }
        
//        Task{
            gameStats.removeAll()
//            gameStatCompare.removeAll()
            
            await getStatSets(pIDs: [p1ID, p2ID], criteria: criteria)
//            await getStatSets(pID: p2ID, criteria: criteria)
//        }
        
//        return allPlayers
    }
    
    // Compare data
    @MainActor
    func getStatSets(pIDs: [String], criteria: String) async {
        // Validate URL.
        for pID in pIDs {
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
                    
                    gameStats.append(StatSeriesAll(id: pID, statData: ss))
                    
                    
                    
                    //                if let at = ss.first(where: { $0.category == "\(criteria)"})?.statData {
                    //                    gameStatCompare.append(StatSeriesCompare(id: pID, statSeries: at))
                    ////                    var test = gameStats[0].statData.first(where: { $0.category == "PTS"})
                    ////                    print(at)
                    //                }
                }
            } catch {
                return
            }
        }
        
        getChartData(criteria: criteria, pIDs: pIDs)
    }
    
    func getChartData(criteria: String, pIDs: [String]) {
        gameStatCompare.removeAll()

        for pID in pIDs {
            if let gss = gameStats.first(where: { $0.id == pID}) {
                let statSeries = gss.statData
                let p = Int(pID) == p1?.playerID ? p1 : p2
                
                if let at = statSeries.first(where: { $0.category == "\(criteria)"})?.statData {
                    gameStatCompare.append(StatSeriesCompare(id: pID, statSeries: at, color: Color((p?.team.priColor)!)))
                }
            }
        }
    }
    
    // TeamsViewModel
    @MainActor
    func getTeams() async -> [Team] {
        var teams = Team.teamData
        
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
                return []
            }
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["resultSets"] as? [[String: Any]]
                else {
                    print("This isn't working")
                    return []
                }
                
                guard let headers = data[0]["headers"] as? [String],
                      let standings = data[0]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return []
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
                    return []
                }
                
                for t in standings {
                    let tID = t[idI] as! Int
                    
                    guard let x = teams.firstIndex(where: { $0.teamID == tID})
                    else {
                        print("Couldn't find team")
                        return []
                    }

                    teams[x].wins = t[wI] as? Int
                    teams[x].loss = t[lI] as? Int
                    teams[x].divRank = t[drI] as? Int
                    teams[x].leagueRank = t[lrI] as? Int
                }
            }
        } catch {
            return []
        }
//        print(games.count)
        return teams
    }
    
    // TeamDetailViewModel
    func getTeamRoster(teamID: String) async -> [Player] {
//        teamRoster.removeAll()
        var roster = [Player]()
        
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
                            roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, nickName: p["NICKNAME"] as? String, age: p["AGE"] as? Int, rank: 0, teamID: p["TeamID"] as! Int, jersey: p["NUM"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, birthDate: p["BIRTH_DATE"] as? String, experience: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String))
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
    }
    
    // Player Info
    @MainActor
    func getPlayerInfo(pID: Int) async {
//        teamRoster.removeAll()
//        var roster = [Player]()
        var player : Player
        
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
        return
    }
}
