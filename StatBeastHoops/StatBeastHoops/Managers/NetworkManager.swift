//
//  NetworkManager.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/13/23.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkManager")
 
    @Published var notConnected: Bool = false // Used on the HomeView to present a notification if not connected.
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            // The monitor runs on a background thread so we need to publish on the main thread
            DispatchQueue.main.async {
                if path.status == .satisfied {
//                    print("We're connected!")
                    self.notConnected = false
                } else {
//                    print("No connection.")
                    self.notConnected = true
                }
            }
        }
        monitor.start(queue: queue)
    }
}
