//
//  GlossaryView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 5/2/24.
//

import SwiftUI

struct GlossaryView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    let glossary = ["GP": "Games Played", "GS": "Games Started", "MIN": "Minutes Played", "PTS": "Points", "FGM": "Field Goals Made", "FGA": "Field Goals Attempted", "FG %": "Field Goal Percentage", "FG3M": "3 Point Field Goals Made", "FG3A": "3 Point Field Goals Attempted", "FG3 %": "3 Point Field Goal Percentage", "FTM": "Free Throws Made", "FTA": "Free Throws Attempted", "FT %": "Free Throw Percentage", "OREB": "Offensive Rebounds",  "DREB": "Defensive Rebounds", "REB": "Rebounds", "AST": "Assists", "TOV": "Turnovers", "STL": "Steals", "BLK": "Blocks", "PF": "Personal Fouls", "FP": "Fantasy Points", "DD2": "Double Doubles", "TD3": "Triple Doubles", "+/-": "Plus-Minus"]
    
    let terms = ["GP", "GS", "MIN", "FGM", "FGA", "FG %", "FG3M", "FG3A", "FG3 %", "FTM", "FTA", "FT %", "OREB", "DREB", "REB", "AST", "STL", "BLK", "TOV", "PF", "PTS", "FP"]
    
    var body: some View {
        ZStack {
            VStack {
                Text("Glossary")
                    .font(.title2)
                    .fontWeight(.thin)
                
                Divider()
                    .padding(.bottom)
                
                ForEach(terms, id: \.self) { term in
                    HStack {
                        Text(term).bold()
                        Spacer()
                        Text(glossary[term] ?? "-")
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .padding(30)
            .shadow(radius: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    withAnimation {
                        playerDataManager.showGlossary = false
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .buttonStyle(.borderedProminent)
                .tint(.secondary)
            }
        }
    }
}

#Preview {
    GlossaryView().environmentObject(PlayerDataManager())
}
