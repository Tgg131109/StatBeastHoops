//
//  FollowingView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct FollowingView: View {
    @EnvironmentObject var vm : FavoritesManager
    @EnvironmentObject var teamDataManager : TeamDataManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Players") {
                    if vm.getPlayers().isEmpty {
                        ZStack {
                            Image(uiImage: Team.teamData[30].logo).resizable().aspectRatio(contentMode: .fill).clipShape(.rect(cornerRadius: 16)).opacity(0.1).padding().blur(radius: 3.0)
                            
                            Text("No saved players")
                        }
                    } else {
                        ForEach(vm.getPlayers(), id: \.playerID) { player in
                            NavigationLink {
                                PlayerDetailView(p: player.team.roster?.first(where: { $0.playerID == player.playerID }) ?? player)
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
                            Image(uiImage: Team.teamData[30].logo).resizable().aspectRatio(contentMode: .fill).clipShape(.rect(cornerRadius: 16)).opacity(0.1).padding().blur(radius: 3.0)
                            
                            Text("No saved teams")
                        }
                    } else {
                        ForEach(vm.getTeams(), id: \.teamID) { team in
                            NavigationLink {
                                TeamDetailView(team: team)
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
                            Image(uiImage: Team.teamData[30].logo).resizable().aspectRatio(contentMode: .fill).clipShape(.rect(cornerRadius: 16)).opacity(0.1).padding().blur(radius: 3.0)
                            
                            Text("No saved matchups")
                        }
                    } else {
                        ForEach(vm.getMatchups(), id: \.id) { matchup in
                            NavigationLink {
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(matchup.p1.playerID).png")) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Image(uiImage: matchup.p1.team.logo).resizable().aspectRatio(contentMode: .fill)
                                    }
                                    .frame(width: 40, height: 30, alignment: .bottom)
                                    
                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(matchup.p2.playerID).png")) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Image(uiImage: matchup.p2.team.logo).resizable().aspectRatio(contentMode: .fill)
                                    }
                                    .frame(width: 40, height: 30, alignment: .bottom)
                                    .padding(.leading, -30)
                                    
                                    Text(matchup.p1.firstName)
                                    
                                    Text("vs").foregroundStyle(.secondary)
                                    
                                    Text(matchup.p2.firstName)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Following").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        NavButtonsView()
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FollowingView().environmentObject(PlayerDataManager()).environmentObject(FavoritesManager())
}
