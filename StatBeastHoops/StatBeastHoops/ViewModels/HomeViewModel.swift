//
//  HomeViewModel.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/20/24.
//

import Foundation
import SwiftUI

class HomeViewModel : ObservableObject {
    
    @MainActor
    func getTodaysGames() async -> [Game] {
        var games = [Game]()
        
        // Validate URL.
        guard let validURL = URL(string: "https://cdn.nba.com/static/json/liveData/scoreboard/todaysScoreboard_00.json")
        else { fatalError("Invalid URL")}
        
        let urlRequest = URLRequest(url: validURL)
        
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

        return games
    }
}
