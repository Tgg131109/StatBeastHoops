//
//  NavButtonsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/19/24.
//

import SwiftUI

struct NavButtonsView: View {
    @StateObject var playerDataManager : PlayerDataManager
    @StateObject var settingsManager : SettingsManager
    @StateObject var locationManager : LocationManager
    @StateObject var soundsManager : SoundsManager
    
//    @Binding var myTeamID : Int
    
//    var pc : UIColor {
//        return Team.teamData.first(where: { $0.teamID == myTeamID })?.priColor ?? Player.demoPlayer.team.priColor
//    }
    
    var body: some View {
        HStack {
//            Button {
//                playerDataManager.currentDetent = .large
//                playerDataManager.needsOverlay = false
//                playerDataManager.showComparePage = true
//            } label: {
//                Image(systemName: "person.line.dotted.person.fill").tint(Color(uiColor: pc))
//            }//.foregroundStyle(Color(uiColor: pc))
//            
            Button {
                playerDataManager.showSettingsPage = true
            } label: {
                Image(systemName: "gearshape")
//                    .tint(Color(uiColor: pc))
            }
        }
//        .sheet(isPresented: $playerDataManager.showComparePage) {
//            CompareView(playerDataManager: playerDataManager, sp: Player.demoPlayer, needsOverlay: false).presentationDetents([.medium, .large, .fraction(0.8), .height(400)],selection: $playerDataManager.currentDetent)
//                .presentationBackgroundInteraction(.enabled)
//        }
//        .sheet(isPresented: $playerDataManager.showSettingsPage) {
//            SettingsView(settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager, myTeamID: $myTeamID)
//        }
    }
}

#Preview {
    NavButtonsView(playerDataManager: PlayerDataManager(), settingsManager: SettingsManager(), locationManager: LocationManager(), soundsManager: SoundsManager())
}
