//
//  TeamsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/10/24.
//

import SwiftUI

struct TeamsView: View {
    @StateObject var apiManager : DataManager
    @State private var searchText = ""
    @State var teams = [Team]()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: HStack { Text("ATLANTIC"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Atlantic" {
                            TeamRowView(apiManager: apiManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("CENTRAL"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Central" {
                            TeamRowView(apiManager: apiManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("SOUTHEAST"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Southeast" {
                            TeamRowView(apiManager: apiManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("NORTHWEST"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Northwest" {
                            TeamRowView(apiManager: apiManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("PACIFIC"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Pacific" {
                            TeamRowView(apiManager: apiManager, team: team)
                        }
                    }
                }
                
                Section(header: HStack { Text("SOUTHWEST"); Spacer(); Text("W      L  ").padding(.trailing) }) {
                    ForEach(teams, id: \.teamID) { team in
                        if !(team.abbr == "NBA") && team.division == "Southwest" {
                            TeamRowView(apiManager: apiManager, team: team)
                        }
                    }
                }
            }.listStyle(.plain)
            .navigationTitle("Teams")
                .toolbarTitleDisplayMode(.inline)
                .onAppear(perform: {   Task{
                    teams = await apiManager.getTeams()
                } })
        }.searchable(text: $searchText)
    }
}

#Preview {
    TeamsView(apiManager: DataManager())
}
