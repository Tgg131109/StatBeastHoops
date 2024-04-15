//
//  SplashView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/16/24.
//

import SwiftUI

@MainActor
struct SplashView: View {
    var apiManager = DataManager()
    var teamDataManager = TeamDataManager()
    var playerDataManager = PlayerDataManager()
    var favoritesManager = FavoritesManager()
    var settingsManager = SettingsManager()
    var locationManager = LocationManager()
    var soundsManager = SoundsManager()
    var playerCompareVM = PlayerCompareViewModel()
    
    @State var isTaskRunning = true
    @State var statusStr = "Getting team standings..."
//    @StateObject var apiManager : DataManager
//    @StateObject var playerDataManager : PlayerDataManager
    
    var body: some View {
        ZStack {
            if isTaskRunning {
                loadingView
            } else {
                ContentView(apiManager: apiManager, teamDataManager: teamDataManager, playerDataManager: playerDataManager, settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager, playerCompareVM: playerCompareVM, favoritesManager: favoritesManager)
            }
        }.onAppear(perform: {   Task{
            // Get team standings
            _ = await teamDataManager.getTeamStandings()
            
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
        VStack {
            Text("StatBeast | Hoops").font(.largeTitle).fontWeight(.black)
            ProgressView().padding().tint(LinearGradient(colors: [Color.blue, Color.red], startPoint: .top, endPoint: .bottom)).controlSize(.large)
//            ProgressView().padding().controlSize(.extraLarge).tint(LinearGradient(colors: [Color.blue, Color.red], startPoint: .bottomLeading, endPoint: .topTrailing))
//            LinearGradient(colors: [Color.pink, Color.purple], startPoint: .bottomLeading, endPoint: .topTrailing)
//            ProgressView().padding().controlSize(.extraLarge).progressViewStyle(LinearProgressViewStyle(tint: Color.yellow))
            Text(statusStr).italic().bold()//.foregroundStyle(.background)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.ultraThinMaterial).foregroundStyle(
            LinearGradient(
                colors: [.teal, .primary],
                startPoint: .topLeading,
                endPoint: .bottom
            )
        )
    }
}

//struct WidthPreferenceKey: PreferenceKey {
//    static var defaultValue: CGFloat = 0
//
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = max(value, nextValue())
//    }
//}
//
//private struct ReadWidthModifier: ViewModifier {
//    private var sizeView: some View {
//        GeometryReader { geometry in
//            Color.clear.preference(key: WidthPreferenceKey.self, value: geometry.size.width)
//        }
//    }
//
//    func body(content: Content) -> some View {
//        content.background(sizeView)
//    }
//}
//
//extension View {
//    func readWidth() -> some View {
//        self
//            .modifier(ReadWidthModifier())
//    }
//}

#Preview {
    SplashView(playerDataManager: PlayerDataManager())
}
