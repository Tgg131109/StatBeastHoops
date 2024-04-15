//
//  HomeView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var apiManager : DataManager
    @StateObject var playerDataManager : PlayerDataManager
    @StateObject var settingsManager : SettingsManager
    @StateObject var locationManager : LocationManager
    @StateObject var soundsManager : SoundsManager
    @StateObject var favoritesManager : FavoritesManager
    
//    @State private var showComparePage: Bool = false
//    @State private var showSettingsPage: Bool = false
    @State private var searchText = ""
    @State private var criterion = "PTS"
    @State private var searchScope = "Current"
    @State var games = [Game]()
    @State var players = [Player]()
    @State var criteria = [String]()
    @State var leaders = [Player]()
    
    @Binding var myTeamID : Int
    
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
                            PlayerRowView(playerDataManager: playerDataManager, favoritesManager: favoritesManager, player: player, rowType: "leaders", criterion: criterion)
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
                            .onChange(of: criterion) { Task{
//                                leaders = await apiManager.getLeaders(cat: criterion)
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
//                    leaders = await apiManager.getLeaders(cat: criterion)
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
//            .overlay(searchOverlay)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Text("StatBeast | Hoops").bold().foregroundStyle(.tertiary)
//                }
//                
//                ToolbarItem(placement: .topBarTrailing) {
//                    HStack {
//                        NavButtonsView(playerDataManager: playerDataManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager, myTeamID: $myTeamID)
//                    }
//                }
//            }.toolbarTitleDisplayMode(.inline)
                
//        }
//        .searchable(text: $searchText)
//        .searchScopes($searchScope) {
//            ForEach(searchScopes, id: \.self) { scope in
//                Text(scope.capitalized)
//            }
//        }
//        .onSubmit(of: .search) {
//            print(searchText)
//            searchText = ""
//        }
//        .sheet(isPresented: $showSettingsPage) {
//            SettingsView()
//        }
    }
    
//    @ViewBuilder
//    private var searchOverlay: some View {
//        if !searchText.isEmpty {
//            List {
//                Section(header: HStack {
//                    Text("Players")
//                }) {
//                    ForEach(playerResults, id: \.playerID) { player in
////                        let team = player.team
////                        let team = Team.teamData.first(where: { $0.teamID == player.teamID})
//                        
//                        NavigationLink {
//                            PlayerDetailView(playerDataManager: playerDataManager, p: player)
//                        } label: {
//                            HStack {
//                                AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { image in
//                                    image
//                                        .resizable()
//                                        .scaledToFit()
//                                } placeholder: {
//                                    Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//                                }
//                                .frame(width: 40, height: 30, alignment: .bottom)
//                                
//                                Text("\(player.firstName) \(player.lastName)")
//                            }
//                        }
//                    }.listRowBackground(Color.clear)
//                }
//                
//                Section(header: HStack {
//                    Text("Teams")
//                }) {
//                    ForEach(teamResults, id: \.teamID) { team in
//                        NavigationLink {
//                            TeamDetailView(apiManager: apiManager, playerDataManager: playerDataManager, team: team)
//                        } label: {
//                            HStack {
//                                Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 40, height: 30)
//                                Text("\(team.homeTown) \(team.teamName)")
//                            }
//                        }
//                    }.listRowBackground(Color.clear)
//                }
//            }.listStyle(.plain)
//                .background(.ultraThinMaterial)
//        }
//    }
}

#Preview {
    HomeView(apiManager: DataManager(), playerDataManager: PlayerDataManager(), settingsManager: SettingsManager(), locationManager: LocationManager(), soundsManager: SoundsManager(), favoritesManager: FavoritesManager(), myTeamID: .constant(Team.teamData[30].teamID))
}
