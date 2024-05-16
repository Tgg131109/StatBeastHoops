//
//  PlayersView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/10/24.
//

import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    @EnvironmentObject var favoritesManager : FavoritesManager
    
    @State private var searchText = ""
    @State private var searchScope = "All"
    @State private var isSearching = false
    @State private var sortBy = "A-Z"
    @State private var teamFilterIDs : [Int] = []
    
    var searchResults: [Player] {
        var sr = playerDataManager.allPlayers
        
        if !searchText.isEmpty {
            sr = sr.filter { ("\($0.firstName) \($0.lastName)").localizedCaseInsensitiveContains(searchText) }
            if searchScope != "All" {
                sr = sr.filter { $0.position!.contains(searchScope) }
            }
        }
        
        switch sortBy {
        case "A-Z":
            break
        case "Z-A":
            sr = sr.reversed()
        case "0-9":
            sr = sr.sorted {
                $0.jersey ?? "" < $1.jersey ?? ""
            }
        case "9-0":
            sr = sr.sorted {
                $1.jersey ?? "" < $0.jersey ?? ""
            }
        default:
            break
        }
        
        if !teamFilterIDs.isEmpty {
            sr = sr.filter { teamFilterIDs.contains($0.teamID) }
        }
        
        return sr
    }
    
    let searchScopes = ["All", "G", "F", "C"]
    
    var body: some View {
        NavigationStack {
            VStack {
                if !isSearching {
                    teamFilterView
                }
                
                ZStack {
                    List {
                        if sortBy == "Team" {
                            ForEach(Team.teamData, id: \.teamID) { team in
                                if searchResults.contains(where: { $0.team.teamID == team.teamID }) {
                                    Section(header: HStack { Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 25); Text(team.teamName.uppercased()).bold().foregroundStyle(.secondary) }) {
                                        ForEach(searchResults, id: \.id) { player in
                                            if player.teamID == team.teamID {
                                                PlayerRowView(player: player, rowType: "players")
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            ForEach(searchResults, id: \.id) { player in
                                PlayerRowView(player: player, rowType: "players")
                            }
                        }
                    }
                    .listSectionSpacing(0)
                    .listStyle(.plain)
                    .safeAreaPadding(EdgeInsets(top: sortBy != "Team" ? 30 : 0, leading: 0, bottom: 30, trailing: 0))
                    
                    VStack {
                        if sortBy != "Team" {
                            HStack {
                                Text(teamFilterIDs.isEmpty ? "Entire League" : "\(teamFilterIDs.count) Teams Selected")
                                
                                if !teamFilterIDs.isEmpty {
                                    Button {
                                        teamFilterIDs.removeAll()
                                    } label: {
                                        Image(systemName: "xmark.circle").foregroundStyle(.red)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(sortBy)
                                Text(Image(systemName: getSortDir()))
                                    .padding(.leading, -4)
                            }
                            .padding(.horizontal)
                            .frame(height: 30)
                            .background(.regularMaterial)
                        } else {
                            HStack {
                                Spacer()
                                
                                Text(sortBy)
                                Text(Image(systemName: getSortDir()))
                            }
                            .font(.caption)
                            .padding(.horizontal)
                            .foregroundStyle(.tertiary)
                            .frame(height: 30)
                        }
                        
                        Spacer()
                        
                        Text("\(searchResults.count) players found")
                            .italic()
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            .background(.regularMaterial)
                        
                    }
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Players").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Menu {
                            Button("Last Name (A-Z)", systemImage: "arrow.up") { withAnimation { sortBy = "A-Z" } }
                            Button("Last Name (Z-A)", systemImage: "arrow.down") { withAnimation { sortBy = "Z-A" } }
                            Button("Jersey Number (0-9)", systemImage: "arrow.up") { withAnimation { sortBy = "0-9" } }
                            Button("Jersey Number (9-0)", systemImage: "arrow.down") { withAnimation { sortBy = "9-0" } }
                            Button("Team", systemImage: "basketball") { withAnimation { sortBy = "Team" } }
                        } label: {
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                        }
                        
                        NavButtonsView()
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchText, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .always), prompt: "Find Players")
        .searchScopes($searchScope) {
            ForEach(searchScopes, id: \.self) { scope in
                Text(scope.capitalized)
            }
        }
        .onSubmit(of: .search) { searchText = "" }
    }
    
    var teamFilterView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Team.teamData, id: \.teamID) { team in
                    Button {
                        if teamFilterIDs.contains(team.teamID) {
                            withAnimation {
                                teamFilterIDs.removeAll(where: { $0 == team.teamID })
                            }
                        } else {
                            withAnimation {
                                teamFilterIDs.append(team.teamID)
                            }
                        }
                    } label: {
                        HStack {
                            Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(height: 30)
                            Text(team.abbr)
                                .font(.callout)
                                .bold()
                                .tint(.primary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                    }
                    .background(teamFilterIDs.contains(team.teamID) ? AnyShapeStyle(Color(team.priColor)) : AnyShapeStyle(.regularMaterial))
                                    .clipShape(.rect(cornerRadius: 6))
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .padding(.bottom, 6)
    }
    
    func getSortDir() -> String {
        var str = "basketball"
        
        if sortBy == "A-Z" || sortBy == "0-9" {
            str  = "arrow.up"
        } else if sortBy == "Z-A" || sortBy == "9-0" {
            str  = "arrow.down"
        }
        
        return str
    }
}

#Preview {
    PlayersView().environmentObject(PlayerDataManager()).environmentObject(FavoritesManager())
}
