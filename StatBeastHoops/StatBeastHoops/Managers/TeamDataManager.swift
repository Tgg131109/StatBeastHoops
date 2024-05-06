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
    @Published var season = "2023-24"
    @Published var todaysGames = [Game]()
    @Published var teamPlayers = [Int : [Player]]()
    @Published var teamCoaches = [Int : [Player]]()
    
    @Published var showCharts = false
    
//    func getTeamStandings() async {
//        teams = Team.teamData
//        
//        // Validate URL.
//        guard let validURL = URL(string: "https://stats.nba.com/stats/leaguestandings?LeagueID=00&Season=2023-24&SeasonType=Regular+Season&SeasonYear=")
//        else { fatalError("Invalid URL")}
//        
//        var urlRequest = URLRequest(url: validURL)
//        urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
////        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
//        
//        do {
//            let (validData, response) = try await URLSession.shared.data(for: urlRequest)
//            
//            guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200 // 200 = OK
//            else {
//                DispatchQueue.main.async {
//                    // Present alert on main thread if there is an error with the URL.
//                }
//                
//                print("JSON object creation failed.")
//                return
//            }
//            
//            // Create json Object from downloaded data above and cast as [String: Any].
//            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
//                guard let data = jsonObj["resultSets"] as? [[String: Any]]
//                else {
//                    print("This isn't working")
//                    return
//                }
//                
//                guard let headers = data[0]["headers"] as? [String],
//                      let standings = data[0]["rowSet"] as? [[Any]]
//                else {
//                    print("This isn't working")
//                    return
//                }
//                
//                
////                print(standings)
////                let idI = headers.firstIndex(of: "TeamID")
//                guard let idI = headers.firstIndex(of: "TeamID"),
//                      let tnI = headers.firstIndex(of: "TeamName"),
//                      let wI = headers.firstIndex(of: "WINS"),
//                      let lI = headers.firstIndex(of: "LOSSES"),
//                      let rI = headers.firstIndex(of: "Record"),
//                      let drI = headers.firstIndex(of: "DivisionRank"),
//                      let lrI = headers.firstIndex(of: "LeagueRank")
//                else {
//                    print("There was an error getting team data")
//                    return
//                }
//                
//                for t in standings {
//                    let tID = t[idI] as! Int
//                    
//                    guard let x = teams.firstIndex(where: { $0.teamID == tID})
//                    else {
//                        print("Couldn't find team")
//                        return
//                    }
//
//                    teams[x].wins = t[wI] as? Int
//                    teams[x].loss = t[lI] as? Int
//                    teams[x].divRank = t[drI] as? Int
//                    teams[x].leagueRank = t[lrI] as? Int
//                }
//            }
//        } catch {
//            return
//        }
////        print(games.count)
////        return teams
//    }
    
//    func getTeamRoster(teamID: Int) async -> [Player] {
////        teamRoster.removeAll()
////        var teamIDs = [String]()
////        
////        for team in teams {
////            teamIDs.append("\(team.teamID)")
////        }
////        
////        let teams = Teams(teamIDs: teamIDs)
////        
////        do {
////            for try await teamID in teams {
////                print(teamID.count)
////            }
////        } catch {
////            print(error)
////        }
//        
//        
//        
//        
////        await ForEach(teams, id: \.teamID) { t in
//////            teamIDs.append(t.teamID)
////            
////        }
//        
//
////        
////        for await id in teamIDs {
////            
////        }
////        for await team in teams {
////        print("here")
//        
//            var roster = [Player]()
////        var team = Team.teamData.first(where: { $0.teamID == teamID })
//        
//            // Validate URL.
//            guard let validURL = URL(string: "https://stats.nba.com/stats/commonteamroster?LeagueID=&Season=2023-24&TeamID=\(teamID)")
//            else { fatalError("Invalid URL")}
//            
//            var urlRequest = URLRequest(url: validURL)
//            urlRequest.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
//            //        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
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
//                    return []
//                }
//                
//                // Create json Object from downloaded data above and cast as [String: Any].
//                if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
//                    guard let data = jsonObj["resultSets"] as? [[String: Any]]
//                    else {
//                        print("This isn't working")
//                        return []
//                    }
//                    
//                    for i in data.indices {
//                        if data[i]["name"] as! String == "CommonTeamRoster" {
//                            guard let headers = data[i]["headers"] as? [Any],
//                                  let players = data[i]["rowSet"] as? [[Any]]
//                            else {
//                                print("This isn't working")
//                                return []
//                            }
//                            
//                            //                        print(players)
//                            
//                            for player in players {
//                                var x = 0
//                                var p = [String : Any]()
//                                
//                                for header in headers {
//                                    //                                print("\(header) : \(player[x])")
//                                    p[header as! String] = player[x]
//                                    x += 1
//                                }
//                                
//                                let nameFormatter = PersonNameComponentsFormatter()
//                                let name = p["PLAYER"]
//                                var fname = ""
//                                var lname = ""
//                                
//                                if let nameComps  = nameFormatter.personNameComponents(from: name as! String) {
//                                    fname = nameComps.givenName ?? p["PLAYER"] as! String
//                                    lname = nameComps.familyName ?? ""
//                                }
//                                
//                                roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, nickName: p["NICKNAME"] as? String, age: p["AGE"] as? Int, rank: 0, teamID: p["TeamID"] as! Int, jersey: p["NUM"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, birthDate: p["BIRTH_DATE"] as? String, experience: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String))
//                            }
//                            
//                            teamPlayers[teamID] = roster
//
//                            if let i = Team.teamData.firstIndex(where: { $0.teamID == teamID }) {
//                                Team.teamData[i].roster = roster
//                            }
//                        } else if data[i]["name"] as! String == "Coaches" {
//                            guard let headers = data[i]["headers"] as? [Any],
//                                  let coaches = data[i]["rowSet"] as? [[Any]]
//                            else {
//                                print("This isn't working")
//                                return []
//                            }
//                            
//                            //                        print(coaches)
//                            
//                            for coach in coaches {
//                                var x = 0
//                                var c = [String : Any]()
//                                
//                                for header in headers {
//                                    //                                print("\(header) : \(coach[x])")
//                                    c[header as! String] = coach[x]
//                                    x += 1
//                                }
//                                
//                                //                            roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: p["PLAYER"] as! String, lastName: "", nickName: p["NICKNAME"] as? String, rank: 0, teamID: p["TEAM_ID"] as! Int, number: p["JERSEY_NUMBER"] as? Int, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? Int, birthDate: p["BIRTH_DATE"] as? String, exp: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String, age: p["AGE"] as? Double))
//                            }
//                        }
//                    }
//                }
//            } catch {
//                return []
//            }
//            //        task.resume()
//        return roster
////        }
//    }
    
    func getTodaysGames() async {
//        var games = [Game]()
        
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
                return
            }
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["scoreboard"] as? [String: Any]
                else {
                    print("This isn't working")
                    return
                }
                
                guard let gameData = data["games"] as? [Any]
                else {
                    print("This isn't working")
                    return
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
                        
                        todaysGames.append(Game(id: id, status: status, clock: clock, time: time, homeTeamID: htID, awayTeamID: atID, homeTeamScore: hScore, awayTeamScore: aScore))
                    } else {
                        print("game data error")
                    }
                }
                
            }
        } catch {
            return
        }
//        print(games.count)
//        return games
    }
    // MARK: this is where the new setup starts for getting data.
    func getStandings() async -> [Team] {
        // league standings endpoint
        
        //['LeagueID', 'SeasonID', 'TeamID', 'TeamCity', 'TeamName', 'Conference', 'ConferenceRecord', 'PlayoffRank', 'ClinchIndicator', 'Division', 'DivisionRecord', 'DivisionRank', 'WINS', 'LOSSES', 'WinPCT', 'LeagueRank', 'Record', 'HOME', 'ROAD', 'L10', 'Last10Home', 'Last10Road', 'OT', 'ThreePTSOrLess', 'TenPTSOrMore', 'LongHomeStreak', 'strLongHomeStreak', 'LongRoadStreak', 'strLongRoadStreak', 'LongWinStreak', 'LongLossStreak', 'CurrentHomeStreak', 'strCurrentHomeStreak', 'CurrentRoadStreak', 'strCurrentRoadStreak', 'CurrentStreak', 'strCurrentStreak', 'ConferenceGamesBack', 'DivisionGamesBack', 'ClinchedConferenceTitle', 'ClinchedDivisionTitle', 'ClinchedPlayoffBirth', 'EliminatedConference', 'EliminatedDivision', 'AheadAtHalf', 'BehindAtHalf', 'TiedAtHalf', 'AheadAtThird', 'BehindAtThird', 'TiedAtThird', 'Score100PTS', 'OppScore100PTS', 'OppOver500', 'LeadInFGPCT', 'LeadInReb', 'FewerTurnovers', 'PointsPG', 'OppPointsPG', 'DiffPointsPG', 'vsEast', 'vsAtlantic', 'vsCentral', 'vsSoutheast', 'vsWest', 'vsNorthwest', 'vsPacific', 'vsSouthwest', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'PreAS', 'PostAS']
        
        let data = await getData(url: "https://stats.nba.com/stats/leaguestandings?LeagueID=00&Season=\(season)&SeasonType=Regular+Season&SeasonYear=")
        
        if !data.isEmpty {
            guard let headers = data[0]["headers"] as? [String],
                  let standings = data[0]["rowSet"] as? [[Any]]
            else {
                print("This isn't working")
                return []
            }
            
//            for standing in standings {
//                var x = 0
//                var p = [String : Any]()
//                
//                for header in headers {
////                    print("\(header) : \(standing[x])")
//                    p[header] = standing[x]
//                    x += 1
//                }
//            }
            
            guard let idI = headers.firstIndex(of: "TeamID"),
//                  let tnI = headers.firstIndex(of: "TeamName"),
                  let wI = headers.firstIndex(of: "WINS"),
                  let lI = headers.firstIndex(of: "LOSSES"),
//                  let rI = headers.firstIndex(of: "Record"),
                  let drI = headers.firstIndex(of: "DivisionRank"),
                  let lrI = headers.firstIndex(of: "LeagueRank")
            else {
                print("There was an error getting team data")
                return []
            }
            
            for standing in standings {
                let tID = standing[idI] as! Int
                
                if let x = Team.teamData.firstIndex(where: { $0.teamID == tID }) {
                    Team.teamData[x].wins = standing[wI] as? Int
                    Team.teamData[x].loss = standing[lI] as? Int
                    Team.teamData[x].divRank = standing[drI] as? Int
                    Team.teamData[x].leagueRank = standing[lrI] as? Int
                }
            }
        }
        
        return Team.teamData
        
        // other endpoints
        // scoreboard - single game details. Might be the wrong info to use here.
        // scoreboardv2 - same as the original with ticket links
        // teamdetails - contains team background section info, championships, awards and social sites
        // winprobabilitypbp
        // teamyearbyyearstats
        // teaminfocommon - contains header stat data
    }
    
    func getTeamInfo(tID: Int) async {
        // teaminfocommon endpoint
        // Available data sets (3)
        // TeamInfoCommon ['TEAM_ID', 'SEASON_YEAR', 'TEAM_CITY', 'TEAM_NAME', 'TEAM_ABBREVIATION', 'TEAM_CONFERENCE', 'TEAM_DIVISION', 'TEAM_CODE', 'TEAM_SLUG', 'W', 'L', 'PCT', 'CONF_RANK', 'DIV_RANK', 'MIN_YEAR', 'MAX_YEAR']
        // TeamSeasonRanks ['LEAGUE_ID', 'SEASON_ID', 'TEAM_ID', 'PTS_RANK', 'PTS_PG', 'REB_RANK', 'REB_PG', 'AST_RANK', 'AST_PG', 'OPP_PTS_RANK', 'OPP_PTS_PG']
        // AvailableSeasons ['SEASON_ID']
        
        let data = await getData(url: "https://stats.nba.com/stats/teaminfocommon?LeagueID=00&Season=&SeasonType=&TeamID=\(tID)")
        
        if !data.isEmpty {
            for i in data.indices {
                guard let headers = data[i]["headers"] as? [String],
                      let dataSets = data[i]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                var info = [String : Any]()
                
                for dataSet in dataSets {
                    var x = 0
                    
                    for header in headers {
//                        print("\(header) : \(standing[x])")
                        info[header] = dataSet[x]
                        x += 1
                    }
                }
                
                if let x = Team.teamData.firstIndex(where: { $0.teamID == tID }) {
                    if data[i]["name"] as! String == "TeamInfoCommon" {
                        Team.teamData[x].minYear = info["MIN_YEAR"] as? String
                        Team.teamData[x].maxYear = info["MAX_YEAR"] as? String
                    } else if data[i]["name"] as! String == "TeamSeasonRanks" {
                        Team.teamData[x].headerStats?["PPG"] = "\(info["PTS_PG"] as? Double ?? 0)"
                        Team.teamData[x].headerStats?["PPG_RANK"] = getRankSuffix(num: info["PTS_RANK"] as? Int ?? 0)
                        
                        Team.teamData[x].headerStats?["RPG"] = "\(info["REB_PG"] as? Double ?? 0)"
                        Team.teamData[x].headerStats?["RPG_RANK"] = getRankSuffix(num: info["REB_RANK"] as? Int ?? 0)
                        
                        Team.teamData[x].headerStats?["APG"] = "\(info["AST_PG"] as? Double ?? 0)"
                        Team.teamData[x].headerStats?["APG_RANK"] = getRankSuffix(num: info["AST_RANK"] as? Int ?? 0)
                        
                        Team.teamData[x].headerStats?["OPG"] = "\(info["OPP_PTS_PG"] as? Double ?? 0)"
                        Team.teamData[x].headerStats?["OPG_RANK"] = getRankSuffix(num: info["OPP_PTS_RANK"] as? Int ?? 0)
                    }
                }
            }
        }
    }
    
    func getTeamDetails(tID: Int) async {
        // teamdetails endpoint
        // Available data sets (8)
        // TeamBackground
        // TeamHistory
        // TeamSocialSites
        // TeamAwardsChampionships
        // TeamAwardsConf
        // TeamAwardsDiv
        // TeamHOF
        // TeamRetired
        
        let data = await getData(url: "https://stats.nba.com/stats/teamdetails?TeamID=\(tID)")
        
        if !data.isEmpty {
            for i in data.indices {
                guard let headers = data[i]["headers"] as? [String],
                      let dataSets = data[i]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return
                }
                
                var info = [String : Any]()
                
                for dataSet in dataSets {
                    var x = 0
                    
                    for header in headers {
//                        print("\(header) : \(dataSet[x])")
                        info[header] = dataSet[x]
                        x += 1
                    }
                }
                
                if let x = Team.teamData.firstIndex(where: { $0.teamID == tID }) {
                    if data[i]["name"] as! String == "TeamBackground" {
                        Team.teamData[x].arena = info["ARENA"] as? String
                        Team.teamData[x].arenaCapacity = info["ARENACAPACITY"] as? String
                        Team.teamData[x].owner = info["OWNER"] as? String
                        Team.teamData[x].gm = info["GENERALMANAGER"] as? String
                        Team.teamData[x].hc = info["HEADCOACH"] as? String
                        Team.teamData[x].dLeague = info["DLEAGUEAFFILIATION"] as? String
                    } else if data[i]["name"] as! String == "TeamSocialSites" {
                        Team.teamData[x].headerStats?[info["ACCOUNTTYPE"] as! String] = info["WEBSITE_LINK"] as? String
                    }
                }
            }
        }
    }
    
    func getTeamSchedule(tID: Int, season: String) async -> [GameStats] {
        // teamgamelogs endpoint
        // TeamGameLogs ['SEASON_YEAR', 'TEAM_ID', 'TEAM_ABBREVIATION', 'TEAM_NAME', 'GAME_ID', 'GAME_DATE', 'MATCHUP', 'WL', 'MIN', 'FGM', 'FGA', 'FG_PCT', 'FG3M', 'FG3A', 'FG3_PCT', 'FTM', 'FTA', 'FT_PCT', 'OREB', 'DREB', 'REB', 'AST', 'TOV', 'STL', 'BLK', 'BLKA', 'PF', 'PFD', 'PTS', 'PLUS_MINUS', 'GP_RANK', 'W_RANK', 'L_RANK', 'W_PCT_RANK', 'MIN_RANK', 'FGM_RANK', 'FGA_RANK', 'FG_PCT_RANK', 'FG3M_RANK', 'FG3A_RANK', 'FG3_PCT_RANK', 'FTM_RANK', 'FTA_RANK', 'FT_PCT_RANK', 'OREB_RANK', 'DREB_RANK', 'REB_RANK', 'AST_RANK', 'TOV_RANK', 'STL_RANK', 'BLK_RANK', 'BLKA_RANK', 'PF_RANK', 'PFD_RANK', 'PTS_RANK', 'PLUS_MINUS_RANK']
        
        let data = await getData(url: "https://stats.nba.com/stats/teamgamelogs?DateFrom=&DateTo=&GameSegment=&LastNGames=&LeagueID=&Location=&MeasureType=&Month=&OppTeamID=&Outcome=&PORound=&PerMode=&Period=&PlayerID=&Season=\(season)&SeasonSegment=&SeasonType=&ShotClockRange=&TeamID=\(tID)&VsConference=&VsDivision=")
        
        var gameStats: [GameStats] = []
        
        if !data.isEmpty {
//            print(data)
            if let x = Team.teamData.firstIndex(where: { $0.teamID == tID }) {
                guard let headers = data[0]["headers"] as? [String],
                      let dataSets = data[0]["rowSet"] as? [[Any]]
                else {
                    print("This isn't working")
                    return []
                }
                
                
                var info = [String : Any]()
                
                for dataSet in dataSets {
                    var x = 0
                    
                    for header in headers {
//                        print("\(header) : \(dataSet[x])")
                        info[header] = dataSet[x]
                        x += 1
                    }
                    
                    gameStats.append(GameStats(gameID: info["GAME_ID"] as! String, gameDate: info["GAME_DATE"] as! String, matchup: info["MATCHUP"] as! String, wl: info["WL"] as! String, min: info["MIN"] as? Double, fgm: info["FGM"] as? Double, fga: info["FGA"] as? Double, fg_pct: info["FG_PCT"] as? Double, fg3m: info["FG3M"] as? Double, fg3a: info["FG3A"] as? Double, fg3_pct: info["FG3_PCT"] as? Double, ftm: info["FTM"] as? Double, fta: info["FTA"] as? Double, ft_pct: info["FT_PCT"] as? Double, oreb: info["OREB"] as? Double, dreb: info["DREB"] as? Double, reb: info["REB"] as? Double, ast: info["AST"] as? Double, stl: info["STL"] as? Double, blk: info["BLK"] as? Double, tov: info["TOV"] as? Double, pf: info["PF"] as? Double, pts: info["PTS"] as? Double, pm: info["PLUS_MINUS"] as? Double, fantasyPts: info["NBA_FANTASY_PTS"] as? Double))
                }
                
                Team.teamData[x].games?[info["SEASON_YEAR"] as! String] = gameStats
//                print(Team.teamData[x].games?[info["SEASON_YEAR"] as! String]?.count)
            }
        }
        
        return gameStats
    }
    
    func getTeamRoster(tID: Int, season: String) async {
        let data = await getData(url: "https://stats.nba.com/stats/commonteamroster?LeagueID=&Season=\(season)&TeamID=\(tID)")
        
        if !data.isEmpty {
            var roster = [Player]()
            
            for i in data.indices {
                if data[i]["name"] as! String == "CommonTeamRoster" {
                    guard let headers = data[i]["headers"] as? [Any],
                          let players = data[i]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return
                    }
                    
                    for player in players {
                        var x = 0
                        var p = [String : Any]()
                        
                        for header in headers {
//                            print("\(header) : \(player[x])")
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
                        
                        roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: fname, lastName: lname, nickName: p["NICKNAME"] as? String, age: p["AGE"] as? Int, rank: 0, teamID: p["TeamID"] as! Int, jersey: p["NUM"] as? String, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? String, birthDate: p["BIRTH_DATE"] as? String, experience: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String))
                    }
                    
                    teamPlayers[tID] = roster

                    if let i = Team.teamData.firstIndex(where: { $0.teamID == tID }) {
                        Team.teamData[i].roster = roster
                    }
                } else if data[i]["name"] as! String == "Coaches" {
                    guard let headers = data[i]["headers"] as? [Any],
                          let coaches = data[i]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return
                    }
                    
//                    print(coaches)
                    for coach in coaches {
                        var x = 0
                        var c = [String : Any]()
                        
                        for header in headers {
//                            print("\(header) : \(coach[x])")
                            c[header as! String] = coach[x]
                            x += 1
                        }
                        
//                        roster.append(Player(playerID: p["PLAYER_ID"] as! Int, firstName: p["PLAYER"] as! String, lastName: "", nickName: p["NICKNAME"] as? String, rank: 0, teamID: p["TEAM_ID"] as! Int, number: p["JERSEY_NUMBER"] as? Int, position: p["POSITION"] as? String, height: p["HEIGHT"] as? String, weight: p["WEIGHT"] as? Int, birthDate: p["BIRTH_DATE"] as? String, exp: p["EXP"] as? String, college: p["SCHOOL"] as? String, howAcquired: p["HOW_ACQUIRED"] as? String, age: p["AGE"] as? Double))
                    }
                }
            }
        }
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
                
                data = d
            }
        } catch {
            return []
        }
        
        return data
    }
    
    func getRankSuffix(num: Int) -> String {
        var str = "-"
        
        if num != 0 {
            let ld = num%10
            
            switch ld {
            case 1:
                str = num != 11 ? "\(num)st" : "\(num)th"
            case 2:
                str = num != 12 ? "\(num)nd" : "\(num)th"
            case 3:
                str = num != 13 ? "\(num)rd" : "\(num)th"
            default:
                str = "\(num)th"
            }
        }
        
        return str
    }
}
