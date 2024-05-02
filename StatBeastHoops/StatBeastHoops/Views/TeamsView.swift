//
//  TeamsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/10/24.
//

import SwiftUI

struct TeamsView: View {
    @EnvironmentObject var teamDataManager : TeamDataManager
    
    @State private var dataReady = false
    @State private var teams = Team.teamData
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var sortBy = "Division"
    @State private var sortDir = "up"
    
    var divisions = ["Atlantic", "Central", "Southeast", "Northwest", "Pacific", "Southwest"]
    
    var conferences = ["East", "West"]
    
    var searchResults: [Team] {
        var sr = teams
        
        if !searchText.isEmpty {
            sr = sr.filter { ("\($0.teamName) \($0.homeTown)").contains(searchText) }
        }
        
        switch sortBy {
        case "Conference":
            sr = sr.sorted {
                $0.leagueRank ?? 6 < $1.leagueRank ?? 6
            }
        case "A-Z":
            break
        case "Z-A":
            sr = sr.reversed()
        default:
            sr = sr.sorted {
                $0.divRank ?? 0 < $1.divRank ?? 0
            }
        }
        
        return sr
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                List {
                    if sortBy == "A-Z" || sortBy == "Z-A" {
                        ForEach(searchResults, id: \.teamID) { team in
                            if !(team.abbr == "NBA") {
                                TeamRowView(team: team)
                            }
                        }
                    } else {
                        ForEach(sortBy == "Division" ? divisions : conferences, id: \.self) { group in
                            Section(header: HStack { Text(group.uppercased()).bold().foregroundStyle(.secondary); Spacer(); Text("W      L  ").padding(.trailing) }) {
                                ForEach(searchResults, id: \.teamID) { team in
                                    if !(team.abbr == "NBA") && (sortBy == "Division" ? team.division : team.conference) == group {
                                        TeamRowView(team: team, sortBy: sortBy)
                                    }
                                }
                            }
                        }
                    }
                }
                .overlay(content: { if !dataReady { ShimmerEffectBox() } })
                .listSectionSpacing(0)
                .listStyle(.plain)
                
                HStack {
                    Text(sortBy)
                    Text(Image(systemName: getSortDir()))
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(height: 24)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Teams").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Menu {
                            Button("Division", systemImage: "square.grid.3x2") { withAnimation { sortBy = "Division" } }
                            Button("Conference", systemImage: "rectangle.split.2x1") { withAnimation { sortBy = "Conference" } }
                            Button("Team Name (A-Z)", systemImage: "arrow.up") { withAnimation { sortBy = "A-Z" } }
                            Button("Team Name (A-Z)", systemImage: "arrow.down") { withAnimation { sortBy = "Z-A" } }
                        } label: {
                            Image(systemName: "arrow.up.and.down.text.horizontal")
                        }
                        
                        NavButtonsView()
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Find Teams")
        .onAppear(perform: {   Task{
            teams = await teamDataManager.getStandings()
            dataReady = true
        } })
    }
    
    func getSortDir() -> String {
        var str = "square.grid.3x2"
        
        switch sortBy {
        case "Conference":
            str = "rectangle.split.2x1"
        case "A-Z":
            str  = "arrow.up"
        case "Z-A":
            str = "arrow.down"
        default:
            break
        }
        
        return str
    }
}

#Preview {
    TeamsView().environmentObject(TeamDataManager())
}
