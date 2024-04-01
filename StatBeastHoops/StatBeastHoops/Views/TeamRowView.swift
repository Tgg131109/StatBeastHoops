//
//  TeamRowView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/15/24.
//

import SwiftUI

struct TeamRowView: View {
    @StateObject var apiManager : DataManager
    @StateObject var playerDataManager : PlayerDataManager
    
    var team : Team
    
    var body: some View {
        NavigationLink {
            TeamDetailView(apiManager: apiManager, playerDataManager: playerDataManager, team: team)
        } label: {
            ZStack {
                Image(uiImage: team.logo).resizable().rotationEffect(.degrees(-35)).aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 60).overlay(Color(.systemBackground).opacity(0.97).frame(maxWidth: .infinity, maxHeight: 60))
                    .clipped().padding(.vertical, -10)
                //                                    .frame(width: 90, height: 40).clipped()
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
            }
        }
    }
}

#Preview {
    TeamRowView(apiManager: DataManager(), playerDataManager: PlayerDataManager(), team: Team.teamData[15])
}
