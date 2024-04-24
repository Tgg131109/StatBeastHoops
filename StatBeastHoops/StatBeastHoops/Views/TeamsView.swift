//
//  TeamsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/10/24.
//

import SwiftUI

struct TeamsView: View {
    @EnvironmentObject var apiManager : DataManager
    @EnvironmentObject var playerDataManager : PlayerDataManager
    @EnvironmentObject var teamDataManager : TeamDataManager
    @EnvironmentObject var favoritesManager : FavoritesManager
    
    @State private var searchText = ""
    @State private var teams = [Team]()
    
    var sections = ["Atlantic", "Central", "Southeast", "Northwest", "Pacific", "Southwest"]
    
    var body: some View {
//        NavigationStack {
            List {
                ForEach(sections, id: \.self) { section in
                    Section(header: HStack { Text(section.uppercased()).bold().foregroundStyle(.secondary); Spacer(); Text("W      L  ").padding(.trailing) }) {
                        ForEach(teams, id: \.teamID) { team in
                            if !(team.abbr == "NBA") && team.division == section {
                                TeamRowView(team: team)
                                    .listRowBackground(TeamRowBackground(team: team))
                            }
                        }
                    }
                }
            }
            .listSectionSpacing(0)
            .listStyle(.insetGrouped)
//            .listSectionSpacing(.compact)
//            .navigationTitle("Teams")
//                .toolbarTitleDisplayMode(.inline)
                .onAppear(perform: {   Task{
                    teams = await apiManager.getTeams()
                } })
//        }.searchable(text: $searchText)
    }
}

#Preview {
    TeamsView()
}
