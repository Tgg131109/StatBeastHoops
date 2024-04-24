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
//    @Published var allPlayers = [Player]()
    @Published var historicalPlayers = [Player]()
    @Published var inactivePlayers = [Player]()
    @Published var leaders = [Player]()
    @Published var playerHeadshots = [PlayerHeadshot]()
    @Published var playerStats = [PlayerStats]()
    @Published var playerGameStats = [PlayerGameStats]()
//    @Published var isTaskRunning = true
    
    
    
//    @Published var searchResults : [Player] = []
    @Published var statCriteria = [String]()
    @Published var statCompare = [StatCompare]()
    @Published var gameStatCompare = [StatSeriesCompare]()
//    @Published var gameStats = [StatSeriesAll]()
    @Published var teams = [Team]()
    @Published var seasons = [String]()
    @Published var teamRoster = [Player]()
//    @Published var rosters = [Int : [Player]]()
    
//    @Published var progress: Double = 0.0
    
    // Stat Compare
    @Published var sp : Player? = nil
    @Published var p1 : Player? = nil
    @Published var p2 : Player? = nil
    
    @Published var currentDetent = PresentationDetent.height(400)
    @Published var needsOverlay = true
    @Published var showComparePage = false
    @Published var showSettingsPage = false
    
    @Published var showCharts = false
    @Published var sortBy = "A-Z"
//    @State var searchText = ""
//    @Published var searchScope = "All"
    
//    let searchScopes = ["All", "G", "F", "C"]
//    @Published var playerStats = [PlayerStats]()
    
    var allPlayers : [Player] {
        var ap : [Player] = []
        
        for team in Team.teamData {
            if let roster = team.roster {
                ap.append(contentsOf: roster)
            }
        }
        
        ap = ap.sorted { $0.lastName < $1.lastName }
        
        return ap
    }
    
    let seasonTypes = ["Preseason","Regular Season", "Postseason", "All-Star", "Play In", "In-Season Tournament"]
    let totalCategories = ["GP", "GS", "MIN", "FGM", "FGA", "FG %", "FG3M", "FG3A", "FG3 %", "FTM", "FTA", "FT %", "OREB", "DREB", "REB", "AST", "STL", "BLK", "TOV", "PF", "PTS"]
    init() {
        for y in 2002...2023 {
            let u = String(y + 1).suffix(2)
            seasons.append("\(y)-\(u)")
        }
        
        seasons.reverse()
    }
    
//    func getSearchResults(searchText: String) {
//        searchResults.removeAll()
//        
////        var allPlayers : [Player] = []
//        
//        for team in Team.teamData {
//            if let roster = team.roster {
//                searchResults.append(contentsOf: roster)
//            }
//        }
//        
////        if searchText.isEmpty {
////            return allPlayers
////        } else {
////            return allPlayers.filter { ("\($0.firstName) \($0.lastName)").contains(searchText) }
////        }
//        
//        if !searchText.isEmpty {
//            searchResults = searchResults.filter { ("\($0.firstName) \($0.lastName)").contains(searchText) }
//        }
//        
//        switch sortBy {
//        case "A-Z":
//            break
//        case "Z-A":
//            searchResults = searchResults.reversed()
//        case "Num":
//            searchResults = searchResults.sorted {
//                $0.jersey ?? "" < $1.jersey ?? ""
//            }
//        default:
//            break
//        }
//        
//        if searchScope != "All" {
//            searchResults = searchResults.filter { $0.position!.contains(searchScope) }
//        }
//    }
    
    func getAllPlayers() async {
        // playerindex endpoint (set Active=1 for only current players)
        // This is just player info, no stats.
        
        // Validate URL.
        guard let validURL = URL(string: "https://stats.nba.com/stats/playerindex?Active=1&AllStar=&College=&Country=&DraftPick=&DraftRound=&DraftYear=&Height=&Historical=1&LeagueID=00&Season=2023-24&TeamID=0&Weight=")
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
                
                for player in players {
                    var i = 0
                    var p = [String : Any]()
                    
                    for header in headers {
                        p[header as! String] = player[i]
                        i += 1
                    }
                    
                    let newPlayer = Player(playerID: p["PERSON_ID"] as! Int, firstName: p["PLAYER_FIRST_NAME"] as! String, lastName: p["PLAYER_LAST_NAME"] as! String, rank: 0, teamID: p["TEAM_ID"] as! Int, jersey: p["JERSEY_NUMBER"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, college: p["COLLEGE"] as? String, country: p["COUNTRY"] as? String, draftYear: p["DRAFT_YEAR"] as? Int, draftNum: p["DRAFT_NUMBER"] as? Int, draftRound: p["DRAFT_ROUND"] as? Int)
                    
                    if let x = Team.teamData.firstIndex(where: { $0.teamID == newPlayer.teamID }) {
                        Team.teamData[x].roster?.append(newPlayer)
                    } else {
                        print("no team found for player - \(newPlayer.firstName) \(newPlayer.lastName)")
//                        self.historicalPlayers.append(newPlayer)
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
    
    // MARK: New player data retrieval setup
    
    func getPlayerInfo(pID: Int) async {
        // [PERSON_ID, FIRST_NAME, LAST_NAME, DISPLAY_FIRST_LAST, DISPLAY_LAST_COMMA_FIRST, DISPLAY_FI_LAST, PLAYER_SLUG, BIRTHDATE, SCHOOL, COUNTRY, LAST_AFFILIATION, HEIGHT, WEIGHT, SEASON_EXP, JERSEY, POSITION, ROSTERSTATUS, GAMES_PLAYED_CURRENT_SEASON_FLAG, TEAM_ID, TEAM_NAME, TEAM_ABBREVIATION, TEAM_CODE, TEAM_CITY, PLAYERCODE, FROM_YEAR, TO_YEAR, DLEAGUE_FLAG, NBA_FLAG, GAMES_PLAYED_FLAG, DRAFT_YEAR, DRAFT_ROUND, DRAFT_NUMBER, GREATEST_75_FLAG]
        let data = await getData(url: "https://stats.nba.com/stats/commonplayerinfo?LeagueID=&PlayerID=\(pID)")
        
        if !data.isEmpty {
            // Available data sets (3)
            // AvailableSeasons
            // CommonPlayerInfo
            // PlayerHeadlineStats
            
            // do something with data in another function.
            // make this section reusable as well.
            for i in data.indices {
                if data[i]["name"] as! String == "CommonPlayerInfo" {
                    guard let headers = data[i]["headers"] as? [Any],
                          let dataSets = data[i]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return
                    }
                    
                    for ds in dataSets {
                        var x = 0
                        var p = [String : Any]()
                        
                        for header in headers {
//                            print("\(header) : \(ds[x])")
                            p[header as! String] = ds[x]
                            x += 1
                        }
                        
                        let tID = p["TEAM_ID"] as! Int
                        
                        if let x = Team.teamData.firstIndex(where: { $0.teamID == tID }) {
                            if let i = Team.teamData[x].roster?.firstIndex(where: { $0.playerID == pID }) {
                                if let isoDate = p["BIRTHDATE"] as? String {
                                    
                                    let dateFormatter = DateFormatter()
                                    let convertDateFormatter = DateFormatter()
                                    
                                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                    
                                    convertDateFormatter.dateFormat = "MMM dd, yyyy"
                                    
                                    let date = dateFormatter.date(from:isoDate)!
                                    let calendar = Calendar.current
                                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                                    let bday = calendar.date(from:components)
                                    let calcAge = calendar.dateComponents([.year], from: bday!, to: Date())
                                    let age = calcAge.year
                                    let birthdate = convertDateFormatter.string(from: date)
                                    
                                    Team.teamData[x].roster?[i].birthDate = birthdate
                                    Team.teamData[x].roster?[i].age = age
                                }
                                
                                if let exp = p["SEASON_EXP"] as? Int {
                                    Team.teamData[x].roster?[i].experience = "\(exp)"
                                }
                            } else {
                                print("No player found")
                            }
                        } else {
                            print("No team found")
                        }
                    }
                }
            }
        }
    }
    
    func getPlayerStatTotals(player: Player) async {
        // playerprofilev2 endpoint
        // Contains career and season info including highs, pre/post season, and college.
        let pID = player.playerID
        let data = await getData(url: "https://stats.nba.com/stats/playerprofilev2?LeagueID=&PerMode=Totals&PlayerID=\(pID)")
        
        if !data.isEmpty {
            // Available data sets (15)
            
            // CareerTotalsCollegeSeason
            // ['PLAYER_ID', 'LEAGUE_ID', 'ORGANIZATION_ID', 'GP', 'GS', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS']
            
            // SeasonTotalsCollegeSeason
            // ['PLAYER_ID', 'SEASON_ID', 'LEAGUE_ID', 'ORGANIZATION_ID', 'SCHOOL_NAME', 'PLAYER_AGE', 'GP', 'GS', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS']
            
            // Highs don't return any useful data. Will be calculated with getPlayerGameStats.
            // CareerHighs
            // SeasonHighs
            // ['PLAYER_ID', 'GAME_DATE', 'VS_TEAM_ID', 'VS_TEAM_CITY', 'VS_TEAM_NAME', 'VS_TEAM_ABBREVIATION', 'STAT', 'STATS_VALUE', 'STAT_ORDER', 'DATE_EST']
            
            // CareerTotalsPreseason
            // CareerTotalsRegularSeason
            // CareerTotalsPostSeason
            // CareerTotalsAllStarSeason
            // ['PLAYER_ID', 'LEAGUE_ID', 'TEAM_ID', 'GP', 'GS', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS']
            
            // SeasonRankingsRegularSeason
            // SeasonRankingsPostSeason
            // ['PLAYER_ID', 'SEASON_ID', 'LEAGUE_ID', 'TEAM_ID', 'TEAM_ABBREVIATION', 'PLAYER_AGE', 'GP', 'GS', 'RANK_MIN', 'RANK_FGM', 'RANK_FGA', 'RANK_FG_PCT', 'RANK_FG3M', 'RANK_FG3A', 'RANK_FG3_PCT', 'RANK_FTM', 'RANK_FTA', 'RANK_FT_PCT', 'RANK_OREB', 'RANK_DREB', 'RANK_REB', 'RANK_AST', 'RANK_STL', 'RANK_BLK', 'RANK_TOV', 'RANK_PTS', 'RANK_EFF']
            
            // SeasonTotalsPreseason
            // SeasonTotalsRegularSeason
            // SeasonTotalsPostSeason
            // SeasonTotalsAllStarSeason
            // ['PLAYER_ID', 'SEASON_ID', 'LEAGUE_ID', 'TEAM_ID', 'TEAM_ABBREVIATION', 'PLAYER_AGE', 'GP', 'GS', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'STL', 'BLK', 'TOV', 'PF', 'PTS']
            
            // NextGame ['GAME_ID', 'GAME_DATE', 'GAME_TIME', 'LOCATION', 'PLAYER_TEAM_ID', 'PLAYER_TEAM_CITY', 'PLAYER_TEAM_NICKNAME', 'PLAYER_TEAM_ABBREVIATION', 'VS_TEAM_ID', 'VS_TEAM_CITY', 'VS_TEAM_NICKNAME', 'VS_TEAM_ABBREVIATION']
            
            // Player -> PlayerSeasonStats = [SeasonType(Pre/Regular/Post/AllStar) : [SeasonID(year) : [SeasonStats]]]
            // Player -> PlayerCareerStats = [SeasonType(Pre/Regular/Post/AllStar) : [CareerStats]]
            // Player -> SeasonHighs = [Highs]
            // Player -> CareerHighs = [Highs]
            
            var pcs : [PlayerCareerStats] = []
            var pss : [PlayerSeasonStats] = []
            
            let proTotals = ["CareerTotalsPreseason", "CareerTotalsRegularSeason", "CareerTotalsPostSeason", "CareerTotalsAllStarSeason", "SeasonTotalsPreseason", "SeasonTotalsRegularSeason", "SeasonTotalsPostSeason", "SeasonTotalsAllStarSeason"]
            
            for i in data.indices {
                guard let dataType = data[i]["name"] as? String,
                      let headers = data[i]["headers"] as? [Any],
                      let statData = data[i]["rowSet"] as? [[Any]]
                else {
                    print("this data is fucked")
                    return
                }
                
                // Match season type string to strings in seasonType array used throughout app.
                var st = ""
                
                if dataType.contains("Preseason") {
                    st = "Preseason"
                } else if dataType.contains("RegularSeason") {
                    st = "Regular Season"
                } else if dataType.contains("PostSeason") {
                    st = "Postseason"
                } else if dataType.contains("AllStarSeason") {
                    st = "All-Star"
                }
                
                if !pcs.contains(where: { $0.seasonType == st }) {
                    pcs.append(PlayerCareerStats(seasonType: st, careerStats: []))
                }
                
                if !pss.contains(where: { $0.seasonType == st }) {
                    pss.append(PlayerSeasonStats(seasonType: st, seasonStats: [:], seasonRankings: [:]))
                }
                
                for ss in statData {
                    var x = 0
                    var p = [String : Any]()
                    
                    for header in headers {
//                        print("\(header) : \(ss[x])")
                        p[header as! String] = ss[x]
                        x += 1
                    }
                    
                    if proTotals.contains(dataType) {
                        var statTotals = StatTotals(gp: p["GP"] as! Int, gs: p["GS"] as! Int, min: p["MIN"] as! Int, fgm: p["FGM"] as! Int, fga: p["FGA"] as! Int, fg_pct: p["FG_PCT"] as! Double, fg3m: p["FG3M"] as! Int, fg3a: p["FG3A"] as! Int, fg3_pct: p["FG3_PCT"] as! Double, ftm: p["FTM"] as! Int, fta: p["FTA"] as! Int, ft_pct: p["FT_PCT"] as! Double, oreb: p["OREB"] as! Int, dreb: p["DREB"] as! Int, reb: p["REB"] as! Int, ast: p["AST"] as! Int, stl: p["STL"] as! Int, blk: p["BLK"] as! Int, tov: p["TOV"] as! Int, pf: p["PF"] as! Int, pts: p["PTS"] as! Int)
                        
                        if dataType.contains("Career") {
                            if let i = pcs.firstIndex(where: { $0.seasonType == st }) {
                                pcs[i].careerStats.append(statTotals)
                            }
                        } else {
                            if let i = pss.firstIndex(where: { $0.seasonType == st }) {
                                statTotals.age = p["PLAYER_AGE"] as? Int
                                statTotals.teamID = p["TEAM_ID"] as? Int
                                pss[i].seasonStats[p["SEASON_ID"] as! String] = statTotals
                            }
                        }
                    } else if dataType.contains("Rankings") {
                        // ['PLAYER_ID', 'SEASON_ID', 'LEAGUE_ID', 'TEAM_ID', 'TEAM_ABBREVIATION', 'PLAYER_AGE', 'GP', 'GS', 'RANK_MIN', 'RANK_FGM', 'RANK_FGA', 'RANK_FG_PCT', 'RANK_FG3M', 'RANK_FG3A', 'RANK_FG3_PCT', 'RANK_FTM', 'RANK_FTA', 'RANK_FT_PCT', 'RANK_OREB', 'RANK_DREB', 'RANK_REB', 'RANK_AST', 'RANK_STL', 'RANK_BLK', 'RANK_TOV', 'RANK_PTS', 'RANK_EFF']
                        let statRankings = Rankings(gp: p["GP"] as! String, gs: p["GS"] as! String, min: p["RANK_MIN"] as? Int, fgm: p["RANK_FGM"] as? Int, fga: p["RANK_FGA"] as? Int, fg_pct: p["RANK_FG_PCT"] as? Int, fg3m: p["RANK_FG3M"] as? Int, fg3a: p["RANK_FG3A"] as? Int, fg3_pct: p["RANK_FG3_PCT"] as? Int, ftm: p["RANK_FTM"] as? Int, fta: p["RANK_FTA"] as? Int, ft_pct: p["RANK_FT_PCT"] as? Int, oreb: p["RANK_OREB"] as? Int, dreb: p["RANK_DREB"] as? Int, reb: p["RANK_REB"] as? Int, ast: p["RANK_AST"] as? Int, stl: p["RANK_STL"] as? Int, blk: p["RANK_BLK"] as? Int, tov: p["RANK_TOV"] as? Int, pts: p["RANK_PTS"] as? Int, eff: p["RANK_EFF"] as? Int)
                        
                        if let i = pss.firstIndex(where: { $0.seasonType == st }) {
                            pss[i].seasonRankings[p["SEASON_ID"] as! String] = statRankings
                        }
                    }
                }
            }
//            let p = player.team.roster?.first(where: { $0.playerID == pID })
//            print("\(p?.seasonStats?.count) | \(p?.seasonStats?[0].seasonStats.count) \(p?.seasonStats?[1].seasonStats.count) \(p?.seasonStats?[2].seasonStats.count) \(p?.seasonStats?[3].seasonStats.count)")
//            print("\(p?.careerStats?.count) | \(p?.careerStats?[0].careerStats.count) \(p?.careerStats?[1].careerStats.count) \(p?.careerStats?[2].careerStats.count) \(p?.careerStats?[3].careerStats.count)")
            
            // Add stats to player object.
            if let h = Team.teamData.firstIndex(where: { $0.teamID == player.teamID }) {
                if let j = Team.teamData[h].roster?.firstIndex(where: { $0.playerID == pID }) {
                    Team.teamData[h].roster?[j].seasonStats = pss
                    Team.teamData[h].roster?[j].careerStats = pcs
                }
            }
        }
    }
    
    func getPlayerGameStats(pID: Int, season: String) async -> [GameStats] {
        // playergamelogs endpoint
        // Provides the same data as the playergamelog (no s) endpoint with rankings
        
        // [SEASON_YEAR, PLAYER_ID, PLAYER_NAME, NICKNAME, TEAM_ID, TEAM_ABBREVIATION, TEAM_NAME, GAME_ID, GAME_DATE, MATCHUP, WL, MIN, FGM, FGA, FG_PCT, FG3M, FG3A, FG3_PCT, FTM, FTA, FT_PCT, OREB, DREB, REB, AST, TOV, STL, BLK, BLKA, PF, PFD, PTS, PLUS_MINUS, NBA_FANTASY_PTS, DD2, TD3, WNBA_FANTASY_PTS, GP_RANK, W_RANK, L_RANK, W_PCT_RANK, MIN_RANK, FGM_RANK, FGA_RANK, FG_PCT_RANK, FG3M_RANK, FG3A_RANK, FG3_PCT_RANK, FTM_RANK, FTA_RANK, FT_PCT_RANK, OREB_RANK, DREB_RANK, REB_RANK, AST_RANK, TOV_RANK, STL_RANK, BLK_RANK, BLKA_RANK, PF_RANK, PFD_RANK, PTS_RANK, PLUS_MINUS_RANK, NBA_FANTASY_PTS_RANK, DD2_RANK, TD3_RANK, WNBA_FANTASY_PTS_RANK, AVAILABLE_FLAG]
        let data = await getData(url: "https://stats.nba.com/stats/playergamelogs?DateFrom=&DateTo=&GameSegment=&LastNGames=&LeagueID=&Location=&MeasureType=&Month=&OppTeamID=&Outcome=&PORound=&PerMode=&Period=&PlayerID=\(pID)&Season=\(season)&SeasonSegment=&SeasonType=&ShotClockRange=&TeamID=&VsConference=&VsDivision=")
        
        var pgs = PlayerGameStats(playerID: pID, season: "2023-24", gameStats: [])
        var gameStats : [GameStats] = []
        
        if !data.isEmpty {
            guard let headers = data[0]["headers"] as? [Any],
                  let games = data[0]["rowSet"] as? [[Any]]
            else {
                print("This isn't working")
                return []
            }
            
//            print(headers)
//            print(games.count)
            
            for game in games {
                var x = 0
                var p = [String : Any]()
                
                for header in headers {
//                    print("\(header) : \(game[x])")
                    p[header as! String] = game[x]
                    x += 1
                }
                
                let gs = GameStats(gameID: p["GAME_ID"] as! String, gameDate: p["GAME_DATE"] as! String, matchup: p["MATCHUP"] as! String, wl: p["WL"] as! String, min: p["MIN"] as? Double, fgm: p["FGM"] as? Double, fga: p["FGA"] as? Double, fg_pct: p["FG_PCT"] as? Double, fg3m: p["FG3M"] as? Double, fg3a: p["FG3A"] as? Double, fg3_pct: p["FG3_PCT"] as? Double, ftm: p["FTM"] as? Double, fta: p["FTA"] as? Double, ft_pct: p["FT_PCT"] as? Double, oreb: p["OREB"] as? Double, dreb: p["DREB"] as? Double, reb: p["REB"] as? Double, ast: p["AST"] as? Double, stl: p["STL"] as? Double, blk: p["BLK"] as? Double, tov: p["TOV"] as? Double, pf: p["PF"] as? Double, pts: p["PTS"] as? Double)
                
//                pgs.gameStats.append(gameStats)
                gameStats.append(gs)
            }
            
            // We need to check if these season already exist and remove them if so.
            // We might even do this at the beginning to prevent the call if the data already exists.
            // We'll have to keep ongoing games in mind if we go with the second approach
//            playerGameStats.append(pgs)
        }
        
        return gameStats
    }
    
    func getData(url: String) async -> [[String: Any]] {
        var data : [[String: Any]] = []
        // Validate URL.
        guard let validURL = URL(string: url)
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
                guard let d = jsonObj["resultSets"] as? [[String: Any]]
                else {
                    print("This isn't working")
                    return []
                }
                
//                print("got data")
                data = d
            }
        } catch {
            return []
        }
        
        return data
    }
}
