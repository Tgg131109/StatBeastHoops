//
//  CompareSetupView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import SwiftUI

struct CompareSetupView: View {
    @StateObject var vm : PlayerCompareViewModel
    @StateObject var cvm : CompareViewModel
    @StateObject var playerDataManager : PlayerDataManager
    
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
                            PlayerSearchView(cvm: cvm, vm: vm, playerDataManager: playerDataManager, p: 1)
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
                            PlayerSearchView(cvm: cvm, vm: vm, playerDataManager: playerDataManager, p: 2)
                        } label: {
                            HStack {
                                Spacer()
                                Text("\(cvm.p2!.firstName) \(cvm.p2!.lastName)").foregroundStyle(.secondary)
                            }
                        }
                    }
                }//.listRowBackground(Material.regularMaterial)
                
                Section("Filters") {
                    HStack {
                        Picker("Season", selection: $season) {
                            ForEach(playerDataManager.seasons, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                    HStack {
                        Picker("Season Type", selection: $seasonType) {
                            ForEach(seasonTypes, id: \.self) {
                                Text($0)
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
                
                vm.showSetup = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Configure Player Compare").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        vm.showSetup = false
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CompareSetupView(vm: PlayerCompareViewModel(), cvm: CompareViewModel(), playerDataManager: PlayerDataManager())
}
