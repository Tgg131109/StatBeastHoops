//
//  TabBarLogoView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/27/24.
//

import SwiftUI

struct TabBarLogoView: View {
    @Binding var myTeamID : Int
    
    var body: some View {
        Image(uiImage: Team.teamData.first(where: { $0.teamID == myTeamID})?.thumbnail ?? Team.teamData[30].thumbnail)
    }
}

#Preview {
    TabBarLogoView(myTeamID: .constant(Team.teamData[30].teamID))
}
