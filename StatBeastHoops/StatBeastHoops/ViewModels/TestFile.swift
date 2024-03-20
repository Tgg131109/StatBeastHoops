//
//  TestFile.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/5/24.
//

import Foundation
import SwiftUI


class TestFile : ObservableObject {
    
    func changeApiKey() {
        if let url = URL(string: "https://stats.nba.com/stats/playerindex?Active=&AllStar=&College=&Country=&DraftPick=&DraftRound=&DraftYear=&Height=&Historical=&LeagueID=00&Season=2022-23&TeamID=0&Weight=") {
//        if let url = URL(string: "https://stats.nba.com/stats/commonallplayers?IsOnlyCurrentSeason=0&LeagueID=00&Season=2019-20") {
//        if let url = URL(string: "https://stats.nba.com/stats/commonteamroster") {
        
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
//            request.setValue("text/plain",forHTTPHeaderField: "Accept")
//            request.setValue("e11f18b4-5015-45ad-8276-18269a7bf047", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let result = String(data: data, encoding: .utf8)
                print("result: \(result ?? "none")")
                
            }
            task.resume()
        }
    }
}
