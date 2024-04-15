//
//  PlayerSearchView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/12/24.
//

import SwiftUI

struct PlayerSearchView: View {
    @StateObject var cvm : CompareViewModel
    @StateObject var vm : PlayerCompareViewModel
//    @StateObject var apiManager : DataManager
    @StateObject var playerDataManager : PlayerDataManager
    
    @State private var searchText = ""
    @State private var criterion = "PTS"
    @State private var searchScope = "Current"
    @State private var selection: Set<String> = []
//    @State private var selection: Int?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var p : Int
    
    let teams = Team.teamData
    let searchScopes = ["All", "Current", "Former"]
    
    var playerResults: [Player] {
        if searchText.isEmpty {
            return playerDataManager.allPlayers
        } else {
            return playerDataManager.allPlayers.filter { ("\($0.firstName) \($0.lastName)").contains(searchText) }
        }
    }
    
    var body: some View {
        //        ScrollView {
        //            LazyVGrid(columns: [GridItem(.fixed(100))]) {
        //            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        VStack {
            List(playerResults, id: \.id, selection: $selection) { player in
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
            
//            Divider()
            
//            Text("Current Player Selections")
            
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
                        }
                    }
                    
                }.frame(maxHeight: 150)
            }
            
            if selection.count > 2 {
                Text("TOO MANY PLAYERS SELECTED!")
                //                selection.remove(at: selection.endIndex)
            }
            
            HStack {
                Button("Done", systemImage: "arrow.left") {
                    let p1 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[0] })
                    let p2 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[1] })
                    
                    cvm.p1 = p1
                    cvm.p2 = p2
                    
                    self.presentationMode.wrappedValue.dismiss()
                }
                .disabled(selection.count != 2)
                .buttonStyle(.bordered)
                .padding()
                
                Button("Compare") {
                    let p1 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[0] })
                    let p2 = playerDataManager.allPlayers.first(where: { $0.id == selection.sorted()[1] })
                    
                    cvm.p1 = p1
                    cvm.p2 = p2
                    
                    Task {
                        await cvm.compareStats(p1ID: "\(cvm.p1!.playerID)", p2ID: "\(cvm.p2!.playerID)", criteria: "PTS")
                        
                    }
                    
                    vm.showSetup = false
                }
                .disabled(selection.count != 2)
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .searchable(text: $searchText)
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
            if let p1ID = cvm.p1?.id {
                selection.insert(p1ID)
            }
            
            if let p2ID = cvm.p2?.id {
                selection.insert(p2ID)
            }
        })
    }
    
    func getPlayers(pID: String) -> Player {
        return playerDataManager.allPlayers.first(where: { $0.playerID == Int(pID) }) ?? Player.demoPlayer
    }
}

#Preview {
    PlayerSearchView(cvm: CompareViewModel(), vm: PlayerCompareViewModel(), playerDataManager: PlayerDataManager(), p: 1)
}
