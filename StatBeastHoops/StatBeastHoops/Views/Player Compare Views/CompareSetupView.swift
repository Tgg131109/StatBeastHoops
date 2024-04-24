//
//  CompareSetupView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import SwiftUI

struct CompareSetupView: View {
    @EnvironmentObject var vm : PlayerCompareViewModel
    @EnvironmentObject var playerDataManager : PlayerDataManager
    @EnvironmentObject var favoritesManager : FavoritesManager
    
    @StateObject var cvm : CompareViewModel
    
    @State private var season = "2023-24"
    @State private var seasonType = "Regular Season"
    
    let seasonTypes = ["Preseason","Regular Season", "Postseason", "All-Star", "Play In", "In-Season Tournament"]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Players") {
                    HStack {
                        Text("Player 1")
                        
                        NavigationLink {
                            PlayerSearchView(cvm: cvm, p: 1)
                        } label: {
                            HStack {
                                Spacer()
                                Text("\(cvm.p1!.firstName) \(cvm.p1!.lastName)").foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Player 2")

                        NavigationLink {
                            PlayerSearchView(cvm: cvm, p: 2)
                        } label: {
                            HStack {
                                Spacer()
                                Text("\(cvm.p2!.firstName) \(cvm.p2!.lastName)").foregroundStyle(.secondary)
                            }
                        }
                    }
                }//.listRowBackground(Material.regularMaterial)
                
                Section("Filters") {
                    Picker("Season", selection: $season) {
                        ForEach(playerDataManager.seasons, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Picker("Season Type", selection: $seasonType) {
                        ForEach(seasonTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section("Saved Matchups") {
                    if favoritesManager.getMatchups().isEmpty {
                        ZStack {
//                            Image(uiImage: Team.teamData[30].logo).resizable().aspectRatio(contentMode: .fill).opacity(0.2).padding().blur(radius: 3.0)
                            
                            Text("No saved matchups").foregroundStyle(.tertiary)
                        }
                    } else {
                        ForEach(favoritesManager.getMatchups(), id: \.self) { player in
                            NavigationLink {
//                                PlayerDetailView(playerDataManager: playerDataManager, p: player)
                            } label: {
//                                HStack {
//                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { image in
//                                        image
//                                            .resizable()
//                                            .scaledToFit()
//                                    } placeholder: {
//                                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//                                    }
//                                    .frame(width: 40, height: 30, alignment: .bottom)
//
//                                    Text("\(player.firstName) \(player.lastName)")
//                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            Button("Compare and Apply") {
                Task {
                    await cvm.compareStats(p1ID: "\(cvm.p1!.playerID)", p2ID: "\(cvm.p2!.playerID)", criteria: "PTS")
                }
                
                vm.showCompareSetup = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Configure Player Compare").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        vm.showCompareSetup = false
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CompareSetupView(cvm: CompareViewModel())
}
