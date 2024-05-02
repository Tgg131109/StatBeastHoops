//
//  StatSelectView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/24/24.
//

import SwiftUI

struct StatSelectView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
//    @State private var selectedColor = "PTS"
    @Binding var selectedStat: String
    @Binding var showStatSelector: Bool
    
    var body: some View {
        VStack {
            Text("Select Stat")
                .bold()
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            Picker("Please choose a stat", selection: $selectedStat) {
                ForEach(playerDataManager.totalCategories, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.inline)
            
            Button("Set Stat") {
                withAnimation {
                    showStatSelector.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    StatSelectView(selectedStat: .constant("PTS"), showStatSelector: .constant(true)).environmentObject(PlayerDataManager())
}
