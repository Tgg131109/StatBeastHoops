//
//  CompareViewModel.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/7/24.
//

import Foundation
import SwiftUI

@MainActor
class CompareViewModel : ObservableObject {
    @Published var compareReady = false
    @Published var statCompare = [StatCompare]()
    @Published var onOffCourtP1 = [StatCompare]()
    @Published var onOffCourtP2 = [StatCompare]()
    @Published var oppOnCourt = [StatCompare]()
    @Published var oppOffCourt = [StatCompare]()
    @Published var gameStats = [StatSeriesAll]()
    @Published var p1: Player = Player.demoPlayer
    @Published var p2: Player = Player.demoPlayer
    @Published var showCompareSetup = false
    @Published var updateCharts = false
    
    let compareCategories = ["GP", "GS", "MIN", "FGM", "FGA", "FG%", "FG3M", "FG3A", "FG3%", "FTM", "FTA", "FT%", "OREB", "DREB", "REB", "AST", "STL", "BLK", "TOV", "PF", "PTS", "+/-", "FP", "DD2", "TD3"]
    
    func compareStats(p1ID: String, p2ID: String, criteria: String) async {
        compareReady = false
        statCompare.removeAll()
        oppOnCourt.removeAll()
        oppOffCourt.removeAll()
        
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
                
//                print(data)
                // Overall stat data for each selected player.
                if data[0]["name"] as! String == "Overall" {
                    guard let headers = data[0]["headers"] as? [Any],
                          let statData = data[0]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return
                    }
                    
                    var sd = statData
                    var sc = [StatCompare]()
                    
                    while sd.count < 2 {
                        if sd.count == 1 {
                            for i in headers.indices {
                                if headers[i] as! String == "PLAYER_ID" {
                                    if !(sd[0][i] as? Int == Int(p1ID)) {
                                        sd.removeAll()
                                        sd.append(Player.emptyData)
                                        sd.append(statData[0])
                                    } else {
                                        sd.append(Player.emptyData)
                                    }
                                }
                            }
                            
                        } else {
                            sd.append(Player.emptyData)
                        }
                    }
                    
                    for i in headers.indices  {
                        var v1 = "\(sd[0][i])"
                        var v2 = "\(sd[1][i])"
                        
                        if (headers[i] as! String).contains("PCT") {
                            for p in 0...1 {
                                if let d = sd[p][i] as? Double {
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
                                if let d = sd[p][i] as? Double {
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
//                    self.statCompareSets["Overall"] = sc.sorted(by: { $1.id > $0.id })
                }
                
                // Vs opponent data.
                if data[1]["name"] as! String == "OnOffCourt" {
                    guard let headers = data[1]["headers"] as? [Any],
                          let statData = data[1]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return
                    }
                    
                    var sd = statData
                    var sc = [StatCompare]()
                    
                    while sd.count < 2 {
                        sd.append(Player.emptyVsData)
//                        if sd.count == 1 {
//                            for i in headers.indices {
//                                if headers[i] as! String == "PLAYER_ID" {
//                                    if !(sd[0][i] as? Int == Int(p1ID)) {
//                                        sd.removeAll()
//                                        sd.append(Player.emptyVsData)
//                                        sd.append(statData[0])
//                                    }
//                                }
//                            }
//                            
//                        } else {
//                            sd.append(Player.emptyVsData)
//                        }
                    }
                    
                    for i in headers.indices  {
                        var v1 = "\(sd[0][i])"
                        var v2 = "\(sd[1][i])"
                        
                        if (headers[i] as! String).contains("PCT") {
                            for p in 0...1 {
                                if let d = sd[p][i] as? Double {
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
                                if let d = sd[p][i] as? Double {
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
                    
                    sc.removeAll(where: { $0.stat == "GROUP_SET" || $0.stat == "GROUP_VALUE" || $0.stat == "PLAYER_ID" || $0.stat == "PLAYER_NAME" || $0.stat == "VS_PLAYER_ID" || $0.stat == "VS_PLAYER_NAME" || $0.stat == "COURT_STATUS" })
                    
                    self.onOffCourtP1 = sc.sorted(by: { $1.id > $0.id })
//                    self.statCompareSets["P1OnOffCourt"] = sc.sorted(by: { $1.id > $0.id })
                }
                
                // Opponent vs data (reverse P1 and P2 ids)
                self.onOffCourtP2 = await getOpponentOnOff(p1ID: p2ID, p2ID: p1ID, criteria: criteria).sorted(by: { $1.id > $0.id })
//                self.statCompareSets["P2OnOffCourt"] = await getOpponentOnOff(p1ID: p2ID, p2ID: p1ID, criteria: criteria).sorted(by: { $1.id > $0.id })
            }
        } catch {
            return
        }
        
        gameStats.removeAll()
        
        await getStatSets(pIDs: [p1ID, p2ID], criteria: criteria)
    }
    
    func getOpponentOnOff(p1ID: String, p2ID: String, criteria: String) async -> [StatCompare] {
        var sc = [StatCompare]()
        
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
                return []
            }
            
            // Create json Object from downloaded data above and cast as [String: Any].
            if let jsonObj = try JSONSerialization.jsonObject(with: validData, options: .mutableContainers) as? [String: Any] {
                guard let data = jsonObj["resultSets"] as? [[String: Any]]
                else {
                    print("This isn't working")
                    return []
                }
                
                // Vs opponent data.
                if data[1]["name"] as! String == "OnOffCourt" {
                    guard let headers = data[1]["headers"] as? [Any],
                          let statData = data[1]["rowSet"] as? [[Any]]
                    else {
                        print("This isn't working")
                        return []
                    }
                    
                    var sd = statData
                    
                    while sd.count < 2 {
                        sd.append(Player.emptyVsData)
//                        if sd.count == 1 {
//                            for i in headers.indices {
//                                if headers[i] as! String == "PLAYER_ID" {
//                                    if !(sd[0][i] as? Int == Int(p1ID)) {
//                                        sd.removeAll()
//                                        sd.append(Player.emptyVsData)
//                                        sd.append(statData[0])
//                                    }
//                                }
//                            }
//                            
//                        } else {
//                            sd.append(Player.emptyVsData)
//                        }
                    }
                    
                    for i in headers.indices  {
                        var v1 = "\(sd[0][i])"
                        var v2 = "\(sd[1][i])"
                        
                        if (headers[i] as! String).contains("PCT") {
                            for p in 0...1 {
                                if let d = sd[p][i] as? Double {
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
                                if let d = sd[p][i] as? Double {
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
                    
                    sc.removeAll(where: { $0.stat == "GROUP_SET" || $0.stat == "GROUP_VALUE" || $0.stat == "PLAYER_ID" || $0.stat == "PLAYER_NAME" || $0.stat == "VS_PLAYER_ID" || $0.stat == "VS_PLAYER_NAME" || $0.stat == "COURT_STATUS" })
                    
                    for i in onOffCourtP1.indices {
                        self.oppOnCourt.append(StatCompare(id: onOffCourtP1[i].id, stat: onOffCourtP1[i].stat, value1: onOffCourtP1[i].value1, value2: sc[i].value1))
                        self.oppOffCourt.append(StatCompare(id: onOffCourtP1[i].id, stat: onOffCourtP1[i].stat, value1: onOffCourtP1[i].value2, value2: sc[i].value2))
                    }
                    
                    self.compareReady = true
                }
            }
        } catch {
            return []
        }
        
        return sc
    }
    
    // Compare data
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
        
//        getChartData(criteria: criteria, pIDs: pIDs)
    }
    
//    func getChartData(criteria: String, pIDs: [String]) {
//        gameStatCompare.removeAll()
//
//        for pID in pIDs {
//            if let gss = gameStats.first(where: { $0.id == pID}) {
//                let statSeries = gss.statData
//                let p = Int(pID) == p1?.playerID ? p1 : p2
//                
//                if let at = statSeries.first(where: { $0.category == "\(criteria)"})?.statData {
//                    gameStatCompare.append(StatSeriesCompare(id: pID, statSeries: at, color: Color((p?.team.priColor)!)))
//                }
//            }
//        }
//    }
    
    func getTotalChange(chartData : [GameStat]) -> Double {
        var change = 0.0
        var chgArr = [Double]()
        
        for i in chartData.indices {
            if i < chartData.count - 1 {
                let start = chartData[i].val
                let end = chartData[i + 1].val
                let result = (end - start)/start * 100
                
                if !(result.isNaN || result.isInfinite) {
                    chgArr.append(result)
                }
            }
        }
        
        change = chgArr.reduce(0.0, +)/Double(chgArr.count)
        
        return change
    }
    
    func getChangeImage(pc: Double) -> String {
        var img = "chart.line.uptrend.xyaxis"
        
        if pc < 0 {
            img = "chart.line.downtrend.xyaxis"
        } else if pc == 0 {
            img = "chart.line.flattrend.xyaxis"
        }
        
        return img
    }
    
    func getChangeTint(pc: Double) -> Color {
        var col = Color.green
        
        if pc < 0 {
            col = Color.red
        } else if pc == 0 {
            col = Color.primary
        }
        
        return col
    }
}
