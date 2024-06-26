//
//  PlayerSearchView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/12/24.
//

import SwiftUI

struct PlayerSearchView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    @StateObject var cvm : CompareViewModel
    
    @State private var searchText = ""
    @State private var criterion = "PTS"
    @State private var searchScope = "Current"
    @State private var selection: Set<String> = []
//    @State private var selection: Int?
    @Binding var dataReady: Bool
    
    var p : Int
    
    let teams = Team.teamData
    let searchScopes = ["All", "Current", "Former"]
    
    var searchResults: [Player] {
        if searchText.isEmpty {
            return playerDataManager.allPlayers
        } else {
            return playerDataManager.allPlayers.filter { ("\($0.firstName) \($0.lastName)").localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            List(searchResults, id: \.id, selection: $selection) { player in
                HStack {
                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 40, height: 30, alignment: .bottom)
                    
                    HStack {
                        Text("\(player.firstName) \(player.lastName)")
                        Text("\(player.team.abbr)").foregroundStyle(.tertiary).font(.callout)
                    }
                    
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
            .listStyle(.insetGrouped)
            .navigationTitle("Find Players")
            .toolbar {
                Button(action: {
                    selection.removeAll()
                }, label: {
                    Text("Clear Selections")
                })
                .disabled(selection.isEmpty)
            }
            
            if !selection.isEmpty {
                List {
                    Section(header: Text("Current Selections")) {
                        ForEach(selection.sorted(), id: \.self) { pID in
                            let p = getPlayers(pID: pID)
                            
                            HStack {
                                AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p.playerID).png")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    Image(uiImage: p.team.logo).resizable().aspectRatio(contentMode: .fill)
                                }
                                .frame(width: 40, height: 30, alignment: .bottom)
                                
                                HStack {
                                    Text("\(p.firstName) \(p.lastName)")
                                    Text("\(p.team.abbr)").foregroundStyle(.tertiary).font(.callout)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    selection.remove(at: selection.firstIndex(where: { $0 == pID})!)
                                } label: {
                                    Label("Important", systemImage: "chair")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
            
            if selection.count > 2 {
                Text("TOO MANY PLAYERS SELECTED!")
            }
            
            HStack {
                Button("Done", systemImage: "arrow.left") {
                    let p1 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[0] })
                    let p2 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[1] })
                    
                    cvm.p1 = p1 ?? Player.demoPlayer
                    cvm.p2 = p2 ?? Player.demoPlayer
                    
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(selection.count != 2)
                .buttonStyle(.bordered)
                .padding()
                
                Button("Compare") {
                    let p1 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[0] })
                    let p2 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[1] })
                    
                    cvm.p1 = p1 ?? Player.demoPlayer
                    cvm.p2 = p2 ?? Player.demoPlayer
                    
                    Task {
                        dataReady = false
                        await cvm.compareStats(p1ID: "\(cvm.p1.playerID)", p2ID: "\(cvm.p2.playerID)", criteria: "PTS")
                        cvm.updateCharts = true
                        dataReady = true
                    }
                    
                    cvm.showCompareSetup = false
                }
                .disabled(selection.count != 2)
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Find players")
        .searchScopes($searchScope) {
            ForEach(searchScopes, id: \.self) { scope in
                Text(scope.capitalized)
            }
        }
        .onSubmit(of: .search) {
            print(searchText)
            searchText = ""
        }
        .onAppear(perform: {
            selection.insert(cvm.p1.id)
            selection.insert(cvm.p2.id)
        })
    }
    
    func getPlayers(pID: String) -> Player {
        return playerDataManager.allPlayers.first(where: { $0.playerID == Int(pID) }) ?? Player.demoPlayer
    }
}

#Preview {
    PlayerSearchView(cvm: CompareViewModel(), dataReady: .constant(true), p: 1).environmentObject(PlayerDataManager())
}
