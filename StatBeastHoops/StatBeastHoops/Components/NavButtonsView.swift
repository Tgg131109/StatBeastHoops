//
//  NavButtonsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/19/24.
//

import SwiftUI

struct NavButtonsView: View {
    @EnvironmentObject var settingsManager : SettingsManager
    
    var viewType : String? = ""
    
    var body: some View {
//        HStack {
            Button {
                settingsManager.showSettingsPage = true
            } label: {
                Image(systemName: "gearshape")
            }
//        }
    }
}

#Preview {
    NavButtonsView()
}
