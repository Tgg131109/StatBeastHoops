//
//  SplashView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/16/24.
//

import SwiftUI

@MainActor
struct SplashView: View {
    @StateObject var apiManager = DataManager()
    @StateObject var teamDataManager = TeamDataManager()
    @StateObject var playerDataManager = PlayerDataManager()
    @StateObject var favoritesManager = FavoritesManager()
    @StateObject var settingsManager = SettingsManager()
    @StateObject var locationManager = LocationManager()
    @StateObject var soundsManager = SoundsManager()
    @StateObject var playerCompareVM = PlayerCompareViewModel()
    
    @State private var isTaskRunning = true
    @State private var statusStr = "Getting team standings..."
    
    var body: some View {
        ZStack {
            if isTaskRunning {
                loadingView
            } else {
                ContentView()
            }
        }
        .environmentObject(apiManager)
        .environmentObject(soundsManager)
        .environmentObject(locationManager)
        .environmentObject(favoritesManager)
        .environmentObject(playerCompareVM)
        .environmentObject(playerDataManager)
        .environmentObject(teamDataManager)
        .environmentObject(settingsManager)
        .onAppear(perform: {   Task{
            // Get team standings
//            _ = await teamDataManager.getTeamStandings()
            
            // Get league leaders
            statusStr = "Getting league leaders..."
            _ = await playerDataManager.getAllLeaders(st: "Regular Season")
            
            // Get today's games
            statusStr = "Getting today's games..."
            _ = await teamDataManager.getTodaysGames()
            
            // Get all players
            statusStr = "Getting players..."
            _ = await playerDataManager.getAllPlayers(season: "2023-24")

            // Get all player stats
//            statusStr = "Getting player stats..."
//            _ = await playerDataManager.getAllPlayerStats()
            
            statusStr = "Done"
            
            withAnimation {
                isTaskRunning = false
            }
        } })
    }
    
    var loadingView: some View {
        ZStack {
            VStack {
                Text("StatBeast | Hoops").font(.largeTitle).fontWeight(.black)
                ProgressView().padding().tint(LinearGradient(colors: [Color.blue, Color.red], startPoint: .top, endPoint: .bottom)).controlSize(.large)
                Text(statusStr).italic().bold()
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.ultraThinMaterial).foregroundStyle(
                LinearGradient(
                    colors: [.teal, .primary],
                    startPoint: .topLeading,
                    endPoint: .bottom
                )
            )
            .overlay(ShimmerEffectBox())
            
            Text("StatBeast | Hoops").font(.largeTitle).fontWeight(.black).foregroundStyle(.ultraThickMaterial).shadow(radius: 10)
        }
    }
}

#Preview {
    SplashView()
}
