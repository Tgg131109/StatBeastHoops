//
//  ContentView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject var apiManager : DataManager
    @StateObject var teamDataManager : TeamDataManager
    @StateObject var playerDataManager : PlayerDataManager
    @StateObject var settingsManager : SettingsManager
    @StateObject var locationManager : LocationManager
    @StateObject var soundsManager : SoundsManager
    @StateObject var playerCompareVM : PlayerCompareViewModel
    @StateObject var favoritesManager : FavoritesManager
//    @StateObject var playerCompareVM : PlayerCompareViewModel
    
//    var apiManager = DataManager()
//    var playerDataManager = PlayerDataManager()
//    var favoritesManager = FavoritesManager()
//    var settingsManager = SettingsManager()
//    var locationManager = LocationManager()
//    var soundsManager = SoundsManager()
    
    @State private var faveTeamID : Int = Team.teamData[30].teamID
    
    @State private var searchText = ""
    @State private var searchScope = "Current"

    let searchScopes = ["All", "Players", "Teams"]
    
    var tintColor : UIColor {
        return Team.teamData.first(where: { $0.teamID == faveTeamID })?.priColor ?? Player.demoPlayer.team.priColor
    }
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(apiManager: apiManager, playerDataManager: playerDataManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager, favoritesManager: favoritesManager, myTeamID: $faveTeamID)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("StatBeast | Hoops").bold().foregroundStyle(.tertiary)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                NavButtonsView(playerDataManager: playerDataManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager)
                            }
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
            }.tabItem {
                let components = Calendar.current.dateComponents([.day], from: Date.now)
                let symbol = "\(components.day ?? 1).square"
                
                Label("Today", systemImage: symbol)
                
            }
                
//            NavigationView {
//                CompareView(playerDataManager: playerDataManager, sp: Player.demoPlayer)
//                    
//            }.tabItem { Label("Compare", systemImage: "square.and.pencil") }
                
            NavigationView {
                FavoritesView(vm: favoritesManager, playerDataManager: playerDataManager, teamDataManager: teamDataManager)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Favorites").bold().foregroundStyle(.tertiary)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                NavButtonsView(playerDataManager: playerDataManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager)
                            }
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
            }.tabItem { Label("Favorites", systemImage: "heart.text.square") }
                
            PlayerCompareView(vm: playerCompareVM, playerDataManager: playerDataManager)
                .tabItem { Label("Compare", systemImage: "person.line.dotted.person") }
            
            NavigationView {
                PlayersView(playerDataManager: playerDataManager, favoritesManager: favoritesManager)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Players").bold().foregroundStyle(.tertiary)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                NavButtonsView(playerDataManager: playerDataManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager)
                            }
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
                    .searchable(text: $searchText)
                    .searchScopes($searchScope) {
                        ForEach(searchScopes, id: \.self) { scope in
                            Text(scope.capitalized)
                        }
                    }
                    .onSubmit(of: .search) {
                        print(searchText)
                        searchText = ""
                    }
            }.tabItem { Label("Players", systemImage: "person.3") }
                
            NavigationView {
                TeamsView(apiManager: apiManager, teamDataManager: teamDataManager, playerDataManager: playerDataManager, favoritesManager: favoritesManager)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Teams").bold().foregroundStyle(.tertiary)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                NavButtonsView(playerDataManager: playerDataManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager)
                            }
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
                    .searchable(text: $searchText)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label {
                    Text("Teams")
                } icon: {
                    TabBarLogoView(myTeamID: $faveTeamID)
                }
            }
        }.tint(Color(tintColor))

//        .overlay(SplashView(playerDataManager: playerDataManager).onDisappear{print("gone")})
        .onAppear(perform: {
            faveTeamID = settingsManager.settingsDict["faveTeamID"] as? Int ?? Team.teamData[30].teamID
        })
        .sheet(isPresented: $playerDataManager.showComparePage) {
            CompareView(playerDataManager: playerDataManager, sp: playerDataManager.sp ?? Player.demoPlayer).presentationDetents([.medium, .large, .fraction(0.8), .height(400)],selection: $playerDataManager.currentDetent)
                .presentationBackgroundInteraction(.enabled)
        }
        .sheet(isPresented: $playerDataManager.showSettingsPage) {
            SettingsView(settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager, myTeamID: $faveTeamID)
        }
    }
}

#Preview {
    ContentView(apiManager: DataManager(), teamDataManager: TeamDataManager(), playerDataManager: PlayerDataManager(), settingsManager: SettingsManager(), locationManager: LocationManager(), soundsManager: SoundsManager(), playerCompareVM: PlayerCompareViewModel(), favoritesManager: FavoritesManager())
}
