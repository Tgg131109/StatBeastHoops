//
//  PlayersView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/10/24.
//

import SwiftUI

struct PlayersView: View {
    @StateObject var playerDataManager : PlayerDataManager
    @StateObject var favoritesManager : FavoritesManager
    
    @State private var searchText = ""
    @State private var searchScope = "Current"
//    @State private var criterion = "PTS"
    
//    @State var players = [Player]()
    @State var leaders = [Player]()
    @State var criteria = [String]()
    
    let searchScopes = ["All", "Current", "Historical"]

    var searchResults: [Player] {
        if searchText.isEmpty {
            return playerDataManager.allPlayers
        } else {
            return playerDataManager.allPlayers.filter { ("\($0.firstName) \($0.lastName)").contains(searchText) }
        }
    }
    
    var body: some View {
//        NavigationStack {
            VStack {
                List {
                    Section("All Players") {
                        ForEach(searchResults, id: \.playerID) { player in
                            if searchText.isEmpty {
                                PlayerRowView(playerDataManager: playerDataManager, favoritesManager: favoritesManager, player: player, rowType: "players")
                            } else {
                                Text("\(player.firstName) \(player.lastName)")
                            }
                        }
                    }
                }.listStyle(.plain)
//                    .navigationTitle("Players")
//                    .toolbarTitleDisplayMode(.inline)
                    .onAppear(perform: {   Task{
//                        leaders = playerDataManager.leaders
//                        players = playerDataManager.allPlayers
//                        criteria = playerDataManager.statCriteria
                    } })
                
                Text("\(searchResults.count) players found").italic().font(.caption).padding(.vertical, 6)
            }
//        }.searchable(text: $searchText)
//            .searchScopes($searchScope) {
//                ForEach(searchScopes, id: \.self) { scope in
//                    Text(scope.capitalized)
//                }
//            }
//            .onSubmit(of: .search) {
//                print(searchText)
//                searchText = ""
//            }
    }
}

#Preview {
    PlayersView(playerDataManager: PlayerDataManager(), favoritesManager: FavoritesManager())
}
