//
//  TestFile.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/5/24.
//

import Foundation
import SwiftUI

class TestFile : NSObject, ObservableObject {
    @Published var totalExpected: Float = 0
    @Published var totalRecieved: Float = 0
    
    var totalDownloaded: Float = 0 {
        didSet {
            self.handleDownloadedProgressPercent?(totalDownloaded)
        }
    }
    typealias progressClosure = ((Float) -> Void)
    var handleDownloadedProgressPercent: progressClosure!
    
    // MARK: - Properties
    private var configuration: URLSessionConfiguration
    private lazy var session: URLSession = {
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        
        return session
    }()
    
    // MARK: - Initialization
    override init() {
        self.configuration = URLSessionConfiguration.background(withIdentifier: "backgroundTasks")
        
        super.init()
    }

    func download(pID: Int, progress: ((Float) -> Void)?) {
        /// bind progress closure to View
        self.handleDownloadedProgressPercent = progress

        /// handle url
        guard let url = URL(string: "https://stats.nba.com/stats/playerprofilev2?LeagueID=&PerMode=Totals&PlayerID=\(pID)") else {
            preconditionFailure("URL isn't true format!")
        }
        
        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
        request.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
        
        let task = session.downloadTask(with: request)
        task.resume()
    }
}

extension TestFile: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        self.totalDownloaded = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(totalBytesExpectedToWrite)
        self.totalExpected = Float(totalBytesExpectedToWrite)
        self.totalRecieved = Float(totalBytesWritten)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        print("downloaded")
    }

    
    
    
    
//    func changeApiKey() {
//        if let url = URL(string: "https://stats.nba.com/stats/playerindex?Active=&AllStar=&College=&Country=&DraftPick=&DraftRound=&DraftYear=&Height=&Historical=&LeagueID=00&Season=2022-23&TeamID=0&Weight=") {
////        if let url = URL(string: "https://stats.nba.com/stats/commonallplayers?IsOnlyCurrentSeason=0&LeagueID=00&Season=2019-20") {
////        if let url = URL(string: "https://stats.nba.com/stats/commonteamroster") {
//        
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.setValue("https://stats.nba.com",forHTTPHeaderField: "Referer")
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
//                print("result: \(result ?? "none")")
//                
//            }
//            task.resume()
//        }
//    }
}
