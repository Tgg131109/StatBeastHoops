//
//  TeamRowView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/15/24.
//

import SwiftUI

struct TeamRowView: View {
    @EnvironmentObject var favoritesManager : FavoritesManager
    @EnvironmentObject var teamDataManager : TeamDataManager
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    var team : Team
    
    var body: some View {
        NavigationLink {
            TeamDetailView(team: team)
        } label: {
            HStack {
                Text("\(team.divRank ?? 0)").bold()
                
                Text("\(team.leagueRank ?? 0)").bold()
                
                Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 40, height: 30)
                
                VStack(alignment: .leading) {
                    Text(team.homeTown).font(.caption)
                    Text(team.teamName).font(.title2).bold().padding(.top, -14)
                }
                
                Spacer()
                
                Text(team.record).bold()
            }
            .padding(.vertical, 1)
        }
    }
}

struct TeamRowBackground: View {
    var team : Team
    
    var body: some View {
        ZStack {
            Image(uiImage: team.logo).resizable().rotationEffect(.degrees(-35)).aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 80)
                .clipped().padding(.vertical, -10)
            
            Color(.systemBackground).opacity(0.97).frame(maxWidth: .infinity, maxHeight: 80)
        }
    }
}
#Preview {
    TeamRowView(team: Team.teamData[15])
}
