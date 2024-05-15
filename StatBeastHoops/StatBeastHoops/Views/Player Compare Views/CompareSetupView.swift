//
//  CompareSetupView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import SwiftUI

struct CompareSetupView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    @EnvironmentObject var favoritesManager : FavoritesManager
    
    @StateObject var cvm: CompareViewModel
    
    @State private var season = "2023-24"
    @State private var seasonType = "Regular Season"
    
    @Binding var dataReady: Bool
    
    let seasonTypes = ["Preseason", "Regular Season", "Postseason", "All-Star", "Play In", "In-Season Tournament"]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Players") {
                    HStack {
                        Text("Player 1")
                        
                        NavigationLink {
                            PlayerSearchView(cvm: cvm, dataReady: $dataReady, p: 1)
                        } label: {
                            HStack {
                                Spacer()
                                Text("\(cvm.p1.firstName) \(cvm.p1.lastName)").foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Player 2")

                        NavigationLink {
                            PlayerSearchView(cvm: cvm, dataReady: $dataReady, p: 2)
                        } label: {
                            HStack {
                                Spacer()
                                Text("\(cvm.p2.firstName) \(cvm.p2.lastName)").foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                Section("Filters") {
                    Picker("Season", selection: $season) {
                        ForEach(playerDataManager.seasons, id: \.self) {
                            Text($0)
                        }
                    }
                    .disabled(true)
                    
                    Picker("Season Type", selection: $seasonType) {
                        ForEach(seasonTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .disabled(true)
                }
                
                Section("Saved Matchups") {
                    if favoritesManager.getMatchups().isEmpty {
                        ZStack {
                            Text("No saved matchups").foregroundStyle(.tertiary)
                        }
                    } else {
                        ForEach(favoritesManager.getMatchups(), id: \.id) { matchup in
                            Button(action: {
                                withAnimation {
                                    cvm.p1 = matchup.p1
                                    cvm.p2 = matchup.p2
                                }
                            }, label: {
                                ZStack {
                                    Text("vs").foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    HStack {
                                        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(matchup.p1.playerID).png")) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            Image(uiImage: matchup.p1.team.logo).resizable().aspectRatio(contentMode: .fill)
                                        }
                                        .frame(width: 40, height: 30, alignment: .bottom)
                                        
                                        Text(matchup.p1.firstName)
                                        
                                        Spacer()
                                        
                                        Text(matchup.p2.firstName)
                                        
                                        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(matchup.p2.playerID).png")) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            Image(uiImage: matchup.p2.team.logo).resizable().aspectRatio(contentMode: .fill)
                                        }
                                        .frame(width: 40, height: 30, alignment: .bottom)
                                    }
                                }
                            })
                            .tint(.primary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            Button("Apply and Compare") {
                Task {
                    dataReady = false
                    await cvm.compareStats(p1ID: "\(cvm.p1.playerID)", p2ID: "\(cvm.p2.playerID)", criteria: "PTS")
                    cvm.updateCharts = true
                    dataReady = true
                }
                
                cvm.showCompareSetup = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Configure Player Compare").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        cvm.showCompareSetup = false
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CompareSetupView(cvm: CompareViewModel(), dataReady: .constant(false)).environmentObject(PlayerDataManager()).environmentObject(FavoritesManager())
}
