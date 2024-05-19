//
//  NavButtonsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/19/24.
//

import SwiftUI

struct NavButtonsView: View {
    @EnvironmentObject var settingsManager : SettingsManager
    
    var body: some View {
        Button {
            settingsManager.showSettingsPage = true
        } label: {
            Image(systemName: "gearshape")
        }
    }
}

#Preview {
    NavButtonsView()
}
