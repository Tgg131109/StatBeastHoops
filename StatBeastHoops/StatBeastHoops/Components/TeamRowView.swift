//
//  TeamRowView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/15/24.
//

import SwiftUI

struct TeamRowView: View {
    @EnvironmentObject var teamDataManager : TeamDataManager
    
    var team: Team
    var sortBy: String = ""
    
    var body: some View {
        NavigationLink {
            TeamDetailView(team: team)
        } label: {
            HStack {
                if sortBy != "" {
                    let rank = sortBy == "Division" ? "\(team.divRank ?? 0)" : "\(team.leagueRank ?? 0)"
                    
                    Text(rank == "0" ? "-" : rank)
                        .bold()
                }
                
                Image(uiImage: team.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 30)
                
                VStack(alignment: .leading) {
                    Text(team.homeTown)
                        .font(.caption)
                    
                    Text(team.teamName)
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                Text(team.record).bold()
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
        }
        .listRowBackground(teamRowBackground)
        .listRowSeparator(.hidden)
    }
    
    var teamRowBackground: some View {
        ZStack(alignment: .center) {
            Image(uiImage: team.logo)
                .resizable()
                .rotationEffect(.degrees(-35))
                .aspectRatio(contentMode: .fill)
                .scaleEffect(1.5)
            
            Color(.systemBackground)
                .opacity(0.9)
        }
        .frame(maxWidth: .infinity, maxHeight: 60)
        .clipped()
    }
}

#Preview {
    TeamRowView(team: Team.teamData[15])
}
