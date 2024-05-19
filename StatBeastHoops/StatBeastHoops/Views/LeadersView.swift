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
    @State var leaders = [Player]()
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(leaders, id: \.playerID) { player in
                    PlayerRowView(player: player, rowType: "leaders", criterion: criterion)
                }
            }
            .listStyle(.insetGrouped)
            .scrollIndicators(.hidden)
            .onAppear(perform: {   Task {
                leaders = await playerDataManager.getStatLeaders(crit: criterion)
                criteria = playerDataManager.totalCategories
                criteria.removeAll(where: { $0 == "GP" || $0 == "GS" })
            } })
        }
        .toolbar {
            if !playerDataManager.showGlossary {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "chevron.backward.circle.fill") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("League Leaders").bold().foregroundStyle(.tertiary)
            }
            
            if !playerDataManager.showGlossary {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Picker("League Leaders", selection: $criterion) {
                            ForEach(criteria, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: criterion) { Task {
                            leaders = await playerDataManager.getStatLeaders(crit: criterion)
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
        }
        .toolbarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay(content: {if playerDataManager.showGlossary { GlossaryView().background(.ultraThinMaterial) } })
    }
}

#Preview {
    LeadersView(criterion: "PTS").environmentObject(PlayerDataManager())
}
