//
//  LeadersView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct LeadersView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    @State var criteria = [String]()
    @State var criterion: String
    
    var leaders: [Player] {
        switch criterion{
        case "PTS":
            return playerDataManager.ptsLeaders
        case "REB":
            return playerDataManager.rebLeaders
        case "AST":
            return playerDataManager.astLeaders
        case "STL":
            return playerDataManager.blkLeaders
        case "BLK":
            return playerDataManager.stlLeaders
        case "FG_PCT":
            return playerDataManager.fgLeaders
        default:
            return playerDataManager.ptsLeaders
//            return Task { await playerDataManager.getLeaders(cat: criterion) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(leaders, id: \.playerID) { player in
                    PlayerRowView(player: player, rowType: "leaders", criterion: criterion)
                }
            }
            .listStyle(.insetGrouped)
            .scrollIndicators(.hidden)
            .onAppear(perform: {   Task{
                criteria = playerDataManager.statCriteria
            } })
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: "chevron.backward.circle.fill") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("League Leaders").bold().foregroundStyle(.tertiary)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Picker("League Leaders", selection: $criterion) {
                        ForEach(criteria, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: criterion) { Task {
                        await playerDataManager.getLeaders(cat: criterion)
                        //                    leaders = playerDataManager.leaders
                    } }
                    
                    Button("", systemImage:"info.circle") {
                        withAnimation {
                            playerDataManager.showGlossary.toggle()
                        }
                    }
                    .tint(.secondary)
                }
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay(content: {if playerDataManager.showGlossary { GlossaryView().background(.ultraThinMaterial) } })
    }
}

#Preview {
    LeadersView(criterion: "PTS").environmentObject(PlayerDataManager())
}
