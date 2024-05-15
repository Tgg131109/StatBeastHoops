//
//  TodayView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 5/4/24.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    @EnvironmentObject var teamDataManager : TeamDataManager
    
    @State private var seasonType = "Regular Season"
    @State private var dataReady = true
    
    var todaysGames: [Game] {
        return teamDataManager.todaysGames
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                            Section {
                                GridRow(dataReady: $dataReady, criteria: ["PTS", "REB"], leaders: [Array(playerDataManager.ptsLeaders.prefix(5)), Array(playerDataManager.rebLeaders.prefix(5))])
                            } header: {
                                HeaderView(stats: ["Points", "Rebounds"])
                            }
                            
                            Section {
                                GridRow(dataReady: $dataReady, criteria: ["AST", "BLK"], leaders: [Array(playerDataManager.astLeaders.prefix(5)), Array(playerDataManager.blkLeaders.prefix(5))])
                            } header: {
                                HeaderView(stats: ["Assists", "Blocks"])
                            }
                            
                            Section {
                                GridRow(dataReady: $dataReady, criteria: ["STL", "FG_PCT"], leaders: [Array(playerDataManager.stlLeaders.prefix(5)), Array(playerDataManager.fgLeaders.prefix(5))])
                            } header: {
                                HeaderView(stats: ["Steals", "FG %"])
                            }
                        }
                        .id(1)
                    }
                    .padding(.top)
                    .scrollIndicators(.hidden)
                    .safeAreaPadding(EdgeInsets(top: 30, leading: 0, bottom: 140, trailing: 0))
                    .onChange(of: seasonType) {
                        withAnimation {
                            proxy.scrollTo(1, anchor: .top)
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Today's Leaders")
                        
                        Spacer()
                        
                        Menu {
                            Picker("Season Type", selection: $seasonType) {
                                ForEach(playerDataManager.leaderSeasonTypes, id: \.self) {
                                    Text($0)
                                }
                            }
                            .background(.clear)
                            .onChange(of: seasonType) { Task {
                                dataReady = false
                                _ = await playerDataManager.getAllLeaders(st: seasonType)
                                dataReady = true
                            } }
                        } label: {
                            Text(seasonType)
                                .font(.subheadline)
                                .tint(.secondary)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    
                    Spacer()
                    
                    HStack {
                        Text("Today's Games")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    
                    Divider()
                    
                    if todaysGames.isEmpty {
                        Text("No games today")
                            .font(.title2)
                            .fontWeight(.thin)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(todaysGames.indices, id: \.self) { i in
                                    VStack {
                                        HStack {
                                            let ht = Team.teamData.first(where: { $0.teamID == todaysGames[i].homeTeamID})
                                            
                                            Image(uiImage: ht!.logo).resizable().frame(width: 20, height: 20)
                                            Text("\(ht!.abbr)")
                                            Spacer()
                                            Text("\(todaysGames[i].homeTeamScore)").bold()
                                        }
                                        
                                        HStack {
                                            let at = Team.teamData.first(where: { $0.teamID == todaysGames[i].awayTeamID})
                                            
                                            Image(uiImage: at!.logo).resizable().frame(width: 20, height: 20)
                                            Text("\(at!.abbr)")
                                            Spacer()
                                            Text("\(todaysGames[i].awayTeamScore)").bold()
                                        }
                                        
                                        Divider().padding(.top, -4)
                                        
                                        Text(todaysGames[i].status).font(.caption2)
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(content: {
                                        RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                            .shadow(radius: 5)
                                    })
                                    .padding(.vertical, 10)
                                    
                                    if i < todaysGames.count - 1 {
                                        Divider().frame(maxHeight: 100)
                                    }
                                }
                            }.padding(.horizontal, 20)
                        }
                        .background(.ultraThinMaterial)
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading) {
                        Text("StatBeast | Hoops")
                            .bold()
                            .foregroundStyle(.tertiary)
                        
                        Text(Date.now, format: .dateTime.day().month().year())
                            .foregroundStyle(.tertiary)
                            .font(.footnote)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        NavButtonsView()
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
    }
}

struct HeaderView: View {
    let stats: [String]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(stats, id: \.self) { stat in
                Text(stat)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
            }
        }
        .padding(.horizontal)
        .background(.background)
    }
}

struct GridRow: View {
    @Binding var dataReady: Bool
    
    let criteria: [String]
    let leaders: [[Player]]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(criteria.indices, id: \.self) { i in
                NavigationLink {
                    LeadersView(criterion: criteria[i])
                } label: {
                    VStack(spacing: 0) {
                        ForEach(leaders[i], id: \.playerID) { player in
                            ZStack(alignment: .center) {
                                Text("\(player.rank ?? 0)")
                                    .font(.system(size: 40))
                                    .fontWeight(.black)
                                    .foregroundStyle(.tertiary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                
                                HStack {
                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
                                    }
                                    .frame(width: 60)
                                    
                                    Spacer()
                                    
                                    Text(getStatStr(criterion: criteria[i], player: player))
                                        .bold()
                                        .font(.title2)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .overlay(content: { if !dataReady { ShimmerEffectBox() } })
                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                }
                .tint(.primary)
            }
        }
        .padding([.horizontal, .bottom])
    }
    
    func getStatStr(criterion: String, player: Player) -> String {
        var valueStr = "-1"
        
        switch criterion {
        case "GP":
            valueStr = String(format: "%.1f", player.gp ?? -1)
        case "MIN":
            valueStr = String(format: "%.1f", player.min ?? -1)
        case "FGM":
            valueStr = String(format: "%.1f", player.fgm ?? -1)
        case "FGA":
            valueStr = String(format: "%.1f", player.fga ?? -1)
        case "FG_PCT":
            valueStr = String(format: "%.1f", (player.fg_pct ?? -1) * 100)
        case "FG3M":
            valueStr = String(format: "%.1f", player.fg3m ?? -1)
        case "FG3A":
            valueStr = String(format: "%.1f", player.fg3a ?? -1)
        case "FG3_PCT":
            valueStr = String(format: "%.1f", (player.fg3_pct ?? -1) * 100)
        case "FTM":
            valueStr = String(format: "%.1f", player.ftm ?? -1)
        case "FTA":
            valueStr = String(format: "%.1f", player.fta ?? -1)
        case "FT_PCT":
            valueStr = String(format: "%.1f", (player.ft_pct ?? -1) * 100)
        case "OREB":
            valueStr = String(format: "%.1f", player.oreb ?? -1)
        case "DREB":
            valueStr = String(format: "%.1f", player.dreb ?? -1)
        case "REB":
            valueStr = String(format: "%.1f", player.reb ?? -1)
        case "AST":
            valueStr = String(format: "%.1f", player.ast ?? -1)
        case "STL":
            valueStr = String(format: "%.1f", player.stl ?? -1)
        case "BLK":
            valueStr = String(format: "%.1f", player.blk ?? -1)
        case "TOV":
            valueStr = String(format: "%.1f", player.tov ?? -1)
        case "EFF":
            valueStr = String(format: "%.1f", player.eff ?? -1)
        default:
            valueStr = String(format: "%.1f", player.pts ?? -1)
        }
        
        return valueStr
    }
}

#Preview {
    TodayView().environmentObject(PlayerDataManager()).environmentObject(TeamDataManager())
}
