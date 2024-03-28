//
//  ContentView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct ContentView: View {
    var apiManager = DataManager()
    var favoritesManager = FavoritesManager()
    var settingsManager = SettingsManager()
    var locationManager = LocationManager()
    var soundsManager = SoundsManager()
    
    @State private var faveTeamID : Int = Team.teamData[30].teamID
    
    var body: some View {
        TabView {
            HomeView(apiManager: apiManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager, myTeamID: $faveTeamID)
                .tabItem {
                    Label("Home", systemImage: "list.dash")
                }
            
            CompareView(apiManager: apiManager, sp: Player.demoPlayer)
                .tabItem {
                    Label("Compare", systemImage: "square.and.pencil")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.text.square")
                }
            
            PlayersView(apiManager: apiManager)
                .tabItem {
                    Label("Players", systemImage: "person.3")
                }
            
            TeamsView(apiManager: apiManager)
                .tabItem {
                    Label {
                        Text("Teams")
                    } icon: {
                        TabBarLogoView(myTeamID: $faveTeamID)
                    }
                }
        }
        .overlay(SplashView(apiManager: apiManager).onDisappear{print("gone")})
        .onAppear(perform: {
            print("tabbar")
            faveTeamID = settingsManager.settingsDict["faveTeamID"] as? Int ?? Team.teamData[30].teamID
        })
    }
}

#Preview {
    ContentView()
}
