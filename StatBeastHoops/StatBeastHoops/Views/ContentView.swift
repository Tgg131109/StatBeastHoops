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
                HomeView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("StatBeast | Hoops").bold().foregroundStyle(.tertiary)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                NavButtonsView()
                            }
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
            }.tabItem {
                let components = Calendar.current.dateComponents([.day], from: Date.now)
                let symbol = "\(components.day ?? 1).square"
                
                Label("Today", systemImage: symbol)
                
            }
            
            NavigationView {
                FavoritesView()
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
            }.tabItem { Label("Following", systemImage: "heart.text.square") }
                
            PlayerCompareView()
                .tabItem { Label("Compare", systemImage: "person.line.dotted.person") }
            
            PlayersView()
                .tabItem { Label("Players", systemImage: "person.3") }
            
            NavigationView {
                TeamsView()
                    
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label {
                    Text("Teams")
                } icon: {
                    TabBarLogoView(myTeamID: $faveTeamID)
                }
            }
        }
        .tint(Color(tintColor))
        .onAppear(perform: {
            faveTeamID = settingsManager.settingsDict["faveTeamID"] as? Int ?? Team.teamData[30].teamID
        })
        .sheet(isPresented: $settingsManager.showSettingsPage) {
            SettingsView(myTeamID: $faveTeamID)
        }
    }
}

#Preview {
    ContentView().environmentObject(SettingsManager())
}
