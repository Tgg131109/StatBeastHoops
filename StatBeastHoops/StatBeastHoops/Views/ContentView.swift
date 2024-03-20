//
//  ContentView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct ContentView: View {
    var apiManager = DataManager()
    
    var body: some View {
        TabView {
            HomeView(apiManager: apiManager)
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
                    Label("Teams", systemImage: "basketball")
                }
        }.overlay(SplashView(apiManager: apiManager).onDisappear{print("gone")})
    }
}

#Preview {
    ContentView()
}
