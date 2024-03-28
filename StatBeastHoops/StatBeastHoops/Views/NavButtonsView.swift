//
//  NavButtonsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/19/24.
//

import SwiftUI

struct NavButtonsView: View {
    @StateObject var apiManager : DataManager
//    @StateObject var favoritesManager = FavoritesManager()
    @StateObject var settingsManager : SettingsManager
    @StateObject var locationManager : LocationManager
    @StateObject var soundsManager : SoundsManager
    
    @Binding var myTeamID : Int
    
    var body: some View {
        HStack {
            Button {
                apiManager.showComparePage = true
            } label: {
                Image(systemName: "person.line.dotted.person.fill")
            }//.foregroundStyle(Color(uiColor: pc))
            
            Button {
                apiManager.showSettingsPage = true
            } label: {
                Image(systemName: "gearshape")
//                let id = settingsManager.settingsDict["faveTeamID"] as? Int
//                let team = Team.teamData.first(where: { $0.teamID == id })
//                
//                Image(uiImage: team?.logo ?? Team.teamData[30].logo)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 25, height: 25)
            }
        }
        .sheet(isPresented: $apiManager.showComparePage) {
            CompareView(apiManager: apiManager, sp: apiManager.sp ?? Player.demoPlayer).presentationDetents([.medium, .large, .fraction(0.8), .height(400)],selection: $apiManager.currentDetent)
                .presentationBackgroundInteraction(.enabled)
        }
        .sheet(isPresented: $apiManager.showSettingsPage) {
            SettingsView(settingsManager: settingsManager, locationManager: locationManager, soundsManager: soundsManager, myTeamID: $myTeamID)
        }
    }
}

#Preview {
    NavButtonsView(apiManager: DataManager(), settingsManager: SettingsManager(), locationManager: LocationManager(), soundsManager: SoundsManager(), myTeamID: .constant(Team.teamData[30].teamID))
}
