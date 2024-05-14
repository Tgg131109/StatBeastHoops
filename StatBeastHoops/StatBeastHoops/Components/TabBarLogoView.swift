//
//  TabBarLogoView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/27/24.
//

import SwiftUI

struct TabBarLogoView: View {
    @EnvironmentObject var settingsManager : SettingsManager
//    @Binding var myTeamID : Int
    
    var body: some View {
        Image(uiImage: Team.teamData.first(where: { $0.teamID == settingsManager.settingsDict["faveTeamID"] as! Int})?.thumbnail ?? Team.teamData[30].thumbnail)
    }
}

#Preview {
    TabBarLogoView().environmentObject(SettingsManager())
}
