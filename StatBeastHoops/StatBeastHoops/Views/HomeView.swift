//
//  HomeView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var apiManager : DataManager
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    @State private var searchText = ""
    @State private var criterion = "PTS"
    @State private var searchScope = "Current"
    
    @State var games = [Game]()
    @State var players = [Player]()
    @State var criteria = [String]()
    @State var leaders = [Player]()

    let teams = Team.teamData
    let searchScopes = ["All", "Players", "Teams"]

    var playerResults: [Player] {
        return players.filter { ("\($0.firstName) \($0.lastName)").contains(searchText) }
    }
    
    var teamResults: [Team] {
        return teams.filter { ("\($0.fullName) \($0.abbr)").contains(searchText) }
    }
    
    var body: some View {
//        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        ForEach(leaders, id: \.playerID) { player in
                            PlayerRowView(player: player, rowType: "leaders", criterion: criterion)
                        }
                    } header: {
                        HStack {
                            Text("League Leaders -")
                            
                            Picker("League Leaders", selection: $criterion) {
                                ForEach(criteria, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.menu).padding(.leading, -15)
                            .onChange(of: criterion) { Task {
                                await playerDataManager.getLeaders(cat: criterion)
                                leaders = playerDataManager.leaders
                            } }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .onAppear(perform: {   Task{
                    leaders = playerDataManager.leaders
                    games = await apiManager.getTodaysGames()
                    criteria = playerDataManager.statCriteria
                    players = playerDataManager.allPlayers
                } })
                
                Divider()
                
                HStack {
                    Text("Today's Games")
                    
                    Text(Date.now, format: .dateTime.day().month().year())
                        .foregroundStyle(.tertiary)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                
                Divider()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(games, id: \.id) { game in
                            VStack {
                                HStack {
                                    let ht = Team.teamData.first(where: { $0.teamID == game.homeTeamID})

                                    Image(uiImage: ht!.logo).resizable().frame(width: 20, height: 20)
                                    Text("\(ht!.abbr)")
                                    Spacer()
                                    Text("\(game.homeTeamScore)").bold()
                                }
                                
                                HStack {
                                    let at = Team.teamData.first(where: { $0.teamID == game.awayTeamID})
                                    
                                    Image(uiImage: at!.logo).resizable().frame(width: 20, height: 20)
                                    Text("\(at!.abbr)")
                                    Spacer()
                                    Text("\(game.awayTeamScore)").bold()
                                }
                                
                                Divider().padding(.top, -4)
                                
                                Text(game.status).font(.caption2)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(content: {
                                RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                    .shadow(radius: 5)
                            })
                            .padding(.vertical, 10)
                            
                            Divider().frame(maxHeight: 100)
                        }
                    }.padding(.horizontal, 20)
                }
                .background(.background)
                .scrollIndicators(.hidden)
                
                Divider()
            }
    }
}

#Preview {
    HomeView().environmentObject(DataManager()).environmentObject(PlayerDataManager())
}
