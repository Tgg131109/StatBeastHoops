//
//  PlayersView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/10/24.
//

import SwiftUI

struct PlayersView: View {
    @StateObject var apiManager : DataManager
    
    @State private var searchText = ""
    @State private var searchScope = "Current"
    @State private var criterion = "PTS"
    
    @State var players = [Player]()
    @State var leaders = [Player]()
    @State var criteria = [String]()
    
    let searchScopes = ["All", "Current", "Historical"]

    var searchResults: [Player] {
        if searchText.isEmpty {
            return leaders
        } else {
//            return players.filter { $0.firstName.contains(searchText) || $0.lastName.contains(searchText) }
            return players.filter { ("\($0.firstName) \($0.lastName)").contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: HStack {
                        Text(searchText.isEmpty ? "League Leaders -" : "Results")
                        
                        if searchText.isEmpty {
                            Picker("League Leaders", selection: $criterion) {
                                ForEach(criteria, id: \.self) {
                                    Text($0)
                                }
                            }.pickerStyle(.menu).padding(.leading, -15)
                        }
                    }) {
                        ForEach(searchResults, id: \.playerID) { player in
                            if searchText.isEmpty {
                                PlayerRowView(apiManager: apiManager, player: player, rowType: searchText.isEmpty ? "leaders" : "players")
                            } else {
                                Text("\(player.firstName) \(player.lastName)")
                            }
                        }
                    }
                }.listStyle(.plain)
                    .navigationTitle("Players")
                    .toolbarTitleDisplayMode(.inline)
                    .onAppear(perform: {   Task{
                        print("appear")
                        players = apiManager.allPlayers
                        leaders = await apiManager.getLeaders()
                        criteria = apiManager.statCriteria
                    } })
                
                Text("\(searchResults.count) players found").italic().font(.caption)
            }
        }.searchable(text: $searchText)
            .searchScopes($searchScope) {
                ForEach(searchScopes, id: \.self) { scope in
                    Text(scope.capitalized)
                }
            }
            .onSubmit(of: .search) {
                print(searchText)
                searchText = ""
            }
    }
}

#Preview {
    PlayersView(apiManager: DataManager())
}
