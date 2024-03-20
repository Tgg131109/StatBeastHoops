//
//  NavButtonsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/19/24.
//

import SwiftUI

struct NavButtonsView: View {
    @StateObject var apiManager : DataManager
    
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
            }
        }
        .sheet(isPresented: $apiManager.showComparePage) {
            CompareView(apiManager: apiManager, sp: apiManager.sp ?? Player.demoPlayer).presentationDetents([.medium, .large, .fraction(0.8), .height(400)],selection: $apiManager.currentDetent)
                .presentationBackgroundInteraction(.enabled)
        }
        .sheet(isPresented: $apiManager.showSettingsPage) {
            SettingsView()
        }
    }
}

#Preview {
    NavButtonsView(apiManager: DataManager())
}
