//
//  ContentView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @EnvironmentObject var settingsManager : SettingsManager
    
    var tintColor : UIColor {
        return settingsManager.settingsDict["accentPref"] as! Bool ? Team.teamData.first(where: { $0.teamID == settingsManager.settingsDict["faveTeamID"] as! Int })?.priColor ?? Player.demoPlayer.team.priColor : UIColor(.accentColor)
    }
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    let components = Calendar.current.dateComponents([.day], from: Date.now)
                    let symbol = "\(components.day ?? 1).square"
                    
                    Label("Today", systemImage: symbol)
                }
            
            FollowingView().tabItem { Label("Following", systemImage: "heart.text.square") }
            
            PlayerCompareView()
                .tabItem { Label("Compare", systemImage: "person.line.dotted.person") }
            
            PlayersView()
                .tabItem { Label("Players", systemImage: "person.3") }
            
            TeamsView()
                .tabItem {
                    if (settingsManager.settingsDict["faveTeamID"] as! Int) < 32 || !(settingsManager.settingsDict["tabbarPref"] as! Bool) {
                        Label("Teams", systemImage: "basketball")
                    } else {
                        Label { Text("Teams") } icon: { TabBarLogoView() }
                    }
                }
        }
        .tint(Color(tintColor))
        .sheet(isPresented: $settingsManager.showSettingsPage) {
            SettingsView().tint(Color(tintColor))
        }
    }
}

#Preview {
    ContentView().environmentObject(SettingsManager())
}
