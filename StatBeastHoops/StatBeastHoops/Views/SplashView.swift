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
            
            // Get team rosters
//            statusStr = "Getting team rosters..."
//            await withTaskGroup(of: [Player].self) { group in
//                for team in Team.teamData {
//                    if team.teamID != 31 {
//                        group.addTask {
//                            return await teamDataManager.getTeamRosters(teamID: team.teamID)
//                        }
//                    }
//                }
//                
////                for await roster in group {
////                }
//            }
            
            // Get league leaders
            statusStr = "Getting league leaders..."
            _ = await playerDataManager.getLeaders(cat: "PTS")
            
            // Get today's games
            statusStr = "Getting today's games..."
//            _ = await playerDataManager.getAllPlayers()
            
            // Get all players
            statusStr = "Getting players..."
            _ = await playerDataManager.getAllPlayers()

            // Get all player stats
            statusStr = "Getting player stats..."
            _ = await playerDataManager.getAllPlayerStats()
            
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
