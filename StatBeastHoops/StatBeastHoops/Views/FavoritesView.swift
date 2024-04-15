//
//  FavoritesView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject var vm : FavoritesManager
//    @StateObject var apiManager : DataManager
    @StateObject var playerDataManager : PlayerDataManager
    @StateObject var teamDataManager : TeamDataManager
    
    var body: some View {
//        NavigationStack {
            List {
                Section("Players") {
                    if vm.getPlayers().isEmpty {
                        ZStack {
                            Image(uiImage: Team.teamData[30].logo).resizable().aspectRatio(contentMode: .fill).opacity(0.2).padding().blur(radius: 3.0)
                            
                            Text("No saved players")
                        }
                    } else {
                        ForEach(vm.getPlayers(), id: \.playerID) { player in
                            NavigationLink {
                                PlayerDetailView(playerDataManager: playerDataManager, favoritesManager: vm, p: player)
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
                                    }
                                    .frame(width: 40, height: 30, alignment: .bottom)
                                    
                                    Text("\(player.firstName) \(player.lastName)")
                                }
                            }
                        }
                    }
                }
                
                Section("Teams") {
                    if vm.getTeams().isEmpty {
                        ZStack {
                            Image(uiImage: Team.teamData[30].logo).resizable().aspectRatio(contentMode: .fill).opacity(0.2).padding().blur(radius: 3.0)
                            
                            Text("No saved teams")
                        }
                    } else {
                        ForEach(vm.getTeams(), id: \.teamID) { team in
                            NavigationLink {
                                TeamDetailView(vm: teamDataManager, playerDataManager: playerDataManager, favoritesManager: vm, team: team)
                            } label: {
                                HStack {
                                    Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 40, height: 30)
                                    Text("\(team.homeTown) \(team.teamName)")
                                }
                            }
                        }
                    }
                }
                
                Section("Matchups") {
                    if vm.getMatchups().isEmpty {
                        ZStack {
                            Image(uiImage: Team.teamData[30].logo).resizable().aspectRatio(contentMode: .fill).opacity(0.2).padding().blur(radius: 3.0)
                            
                            Text("No saved matchups")
                        }
                    } else {
                        ForEach(vm.getMatchups(), id: \.self) { player in
                            NavigationLink {
//                                PlayerDetailView(playerDataManager: playerDataManager, p: player)
                            } label: {
//                                HStack {
//                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { image in
//                                        image
//                                            .resizable()
//                                            .scaledToFit()
//                                    } placeholder: {
//                                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//                                    }
//                                    .frame(width: 40, height: 30, alignment: .bottom)
//                                    
//                                    Text("\(player.firstName) \(player.lastName)")
//                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
//        }
    }
}

#Preview {
    FavoritesView(vm: FavoritesManager(), playerDataManager: PlayerDataManager(), teamDataManager: TeamDataManager())
}
