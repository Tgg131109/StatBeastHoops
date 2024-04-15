//
//  TeamsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/10/24.
//

import SwiftUI

struct TeamsView: View {
    @StateObject var apiManager : DataManager // only for getTeams()
    @StateObject var teamDataManager : TeamDataManager
    @StateObject var playerDataManager : PlayerDataManager
    @StateObject var favoritesManager : FavoritesManager
    
    @State private var searchText = ""
    @State var teams = [Team]()
    
    var body: some View {
//        NavigationStack {
            List {
                Section(header: HStack { Text("ATLANTIC"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Atlantic" {
                            TeamRowView(teamDataManager: teamDataManager, playerDataManager: playerDataManager, favoritesManager: favoritesManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("CENTRAL"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Central" {
                            TeamRowView(teamDataManager: teamDataManager, playerDataManager: playerDataManager, favoritesManager: favoritesManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("SOUTHEAST"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Southeast" {
                            TeamRowView(teamDataManager: teamDataManager, playerDataManager: playerDataManager, favoritesManager: favoritesManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("NORTHWEST"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Northwest" {
                            TeamRowView(teamDataManager: teamDataManager, playerDataManager: playerDataManager, favoritesManager: favoritesManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("PACIFIC"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Pacific" {
                            TeamRowView(teamDataManager: teamDataManager, playerDataManager: playerDataManager, favoritesManager: favoritesManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("SOUTHWEST"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Southwest" {
                            TeamRowView(teamDataManager: teamDataManager, playerDataManager: playerDataManager, favoritesManager: favoritesManager, team: team)
                        }
                    }
                }
            }.listStyle(.plain)
//            .navigationTitle("Teams")
//                .toolbarTitleDisplayMode(.inline)
                .onAppear(perform: {   Task{
                    teams = await apiManager.getTeams()
                } })
//        }.searchable(text: $searchText)
    }
}

#Preview {
    TeamsView(apiManager: DataManager(), teamDataManager: TeamDataManager(), playerDataManager: PlayerDataManager(), favoritesManager: FavoritesManager())
}
