//
//  TeamDetailView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/11/24.
//

import SwiftUI
import Charts

struct TeamDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var playerDataManager: PlayerDataManager
    @EnvironmentObject var vm: TeamDataManager
    @EnvironmentObject var favoritesManager : FavoritesManager
    
    @State private var seasons = [String]()
    @State private var season = "2023-24"
    @State private var seasonType = "Regular Season"
    @State private var selView = 0
//    @State private var roster = [Player]()
//    @State private var gameStats: [GameStats] = []
    @State private var dataReady = false
    @State private var showInfoDrawer = true
    @State private var showCharts = false
    
    @State var team: Team
    
    var isFav: Bool {
        return favoritesManager.contains(team)
    }
    
    var pc: UIColor {
        return team.priColor
    }
    
    var gameStats: [GameStats] {
        return team.games?[season] ?? []
    }
    
    var roster: [Player] {
        return team.roster ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerCard
            
            headerStatRow
            
            VStack {
                teamInfoDrawer
                
                statCard
            }
            .toolbar {
                if !vm.showCharts {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("", systemImage: "chevron.backward.circle.fill") {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .tint(.white.opacity(0.8))
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        FollowButton(p: nil, t: team)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle(team.abbr)
            .toolbarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
//        .overlay(content: {if playerDataManager.showCharts { ChartView(p: p, selectedStats: selectedStats, data: gameStats).background(.ultraThinMaterial) } })
        .onAppear(perform: {   Task{
            await getTeamData()
            dataReady = true
        } })
                
//                ZStack {
//                    Image(uiImage: team.logo).resizable().rotationEffect(.degrees(-35)).aspectRatio(contentMode: .fill)
//                        .frame(maxWidth: .infinity, maxHeight: 250).overlay(Color(.systemBackground).opacity(0.8).frame(maxWidth: .infinity, maxHeight: 250))
//                        .clipped().padding(.trailing, -200).ignoresSafeArea()
//                    
//                    HStack(alignment: .top) {
//                        VStack(alignment: .leading) {
//                            Button {
////                                isFav.toggle()
//                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                    if isFav {
//                                        favoritesManager.remove(team)
//                                    } else {
//                                        favoritesManager.add(team)
//                                    }
//                                }
//                            } label: {
//                                Image(systemName: isFav ? "star.fill" : "star")
//                                Text(isFav ? "Favorited" : "Favorite")
//                            }.padding(7).fontWeight(.bold).font(.caption)
//                                .foregroundStyle(isFav ? AnyShapeStyle(.background) : AnyShapeStyle(.secondary))
//                                .background(
//                                    RoundedRectangle(
//                                          cornerRadius: 20,
//                                          style: .circular
//                                      )
//                                      .stroke(isFav ? Color.primary : Color.secondary, lineWidth: 3)
//                                      .fill(isFav ? AnyShapeStyle(Color(pc)) : AnyShapeStyle(.regularMaterial))
//                                ).padding(.vertical, 20)
//                            
//                            Spacer()
//                            
//                            Text(team.homeTown)
//                            Text(team.teamName).font(.largeTitle).fontWeight(.black).padding(.top, -20)
//                            Text(team.record).fontWeight(.heavy)
//                            Text(team.standing).font(.caption)
//                        }.frame(maxHeight: 170)
//                        
//                        Spacer()
//                        
//                        Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 100, height: 250).shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
//                    }.padding(.horizontal, 20)
//                }.padding(.bottom, -80)
//                
//                Picker("Season", selection: $season) {
//                    ForEach(playerDataManager.seasons, id: \.self) {
//                        Text($0)
//                    }
//                }
//                .pickerStyle(.menu)
//                .background(.regularMaterial).clipShape(.capsule)
//                .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 20)
//                .onChange(of: season) {
////                    apiManager.getChartData(criteria: criteria, pIDs: ["\(p1ID)", "\(p2ID)"])
//                }
//                
//                Picker("View", selection: $selView) {
//                    Text("Season").tag(0)
//                    Text("Roster").tag(1)
//                    Text("Stats").tag(2)
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal, 20)
//                
//                if selView == 0 {
//                    
//                } else if selView == 1 {
//                    List{
//                        ForEach(r, id: \.playerID) { player in
//                            PlayerRowView(player: player, rowType: "roster")
//                        }
//                    }
//                    .listStyle(.plain)
//                } else {
//                    Text(team.fullName)
//                }
//
//                Spacer()
//                
//                Text(team.fullName)
//            }
//            .navigationTitle(team.abbr)
//            .toolbarTitleDisplayMode(.inline)
//        }
//        .onAppear(perform: {   Task{
//            r = await vm.getTeamRoster(teamID: team.teamID)
////            await $vm.getTeamRoster(teamID: "\(team.teamID)")
//        } })
    }
    
    var headerCard: some View {
        ZStack(alignment: .bottom) {
            // Background team logo
            Image(uiImage: team.logo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 150)
                .padding(.trailing, -200)
                .ignoresSafeArea()
                .overlay(Color(pc).opacity(0.8))
            
            ZStack(alignment: .bottom) {
                VStack {
                    HStack(alignment: .top) {
                        // Team standing bar
                        VStack(alignment: .leading) {
                            Text(team.homeTown.uppercased())
                                .padding(.bottom, -10)
                            
                            Text(team.teamName.uppercased())
                                .font(.title2)
                                .fontWeight(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(team.record)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
                                
                                Divider().frame(maxWidth: 2)
                                    .overlay(.white)
                                    .opacity(0.5)
                                
                                Text(team.standing)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
                                
//                                Divider().frame(maxWidth: 2)
//                                    .overlay(.white)
//                                    .opacity(0.5)
//                                
//                                Text(p.position ?? "-")
//                                    .bold()
//                                    .foregroundStyle(.white)
//                                    .opacity(0.8)
                            }
                            .frame(maxHeight: 15)
                            .font(.footnote)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 4,
                                    style: .continuous
                                )
                                .fill(Color(pc)))
                            .padding(.top, -10)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(.ultraThinMaterial)
                .overlay(content: { if !dataReady { ShimmerEffectBox() } })
                .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // Team logo
                Image(uiImage: team.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding([.trailing, .bottom], -10)
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 150)
    }
    
    var headerStatRow: some View {
        HStack(spacing: 0) {
            if dataReady {
                let hs = ["PPG", "RPG", "APG", "OPG"]
                
                ForEach(hs, id: \.self) { k in
                    VStack {
                        Text(k).font(.caption2)
                        
                        Text("\(team.headerStats?[k] ?? "-")")
                            .font(.title3)
                            .bold()
                        
                        Text("\(team.headerStats?["\(k)_RANK"] ?? "-")")
                            .foregroundStyle(.secondary)
                            .bold()
                            .padding(.top, -16)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .border(.regularMaterial)
                }
            } else {
                Text("No Data Available")
                    .font(.title3)
                    .fontWeight(.thin)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .border(.regularMaterial)
            }
        }
        .background(Color(pc))
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
    }
    
    var teamInfoDrawer: some View {
        VStack(spacing: 0) {
            if showInfoDrawer {
                // Row 1
                HStack(spacing: 16) {
                    VStack {
                        Text(team.minYear ?? "-").font(.callout).bold()
                        Text("Founded").font(.caption2).foregroundStyle(.tertiary)
                    }
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text(team.arena ?? "-").font(.callout).bold()
                        Text("Arena").font(.caption2).foregroundStyle(.tertiary)
                    }
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text(team.arenaCapacity ?? "-").font(.callout).bold()
                        Text("Capacity").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
                .frame(maxHeight: 15)
                .padding(.vertical, 14)
                
                Divider()
                    .frame(maxHeight: 1)
                    .overlay(Color(pc))
                    .padding(.horizontal)
                
                // Row 2
                HStack(spacing: 16) {
                    VStack {
                        Text(team.owner ?? "-").font(.callout).bold()
                        Text("Owner").font(.caption2).foregroundStyle(.tertiary)
                    }
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text(team.gm ?? "-").font(.callout).bold()
                        Text("General Manager").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
                .frame(maxHeight: 15)
                .padding(.vertical, 14)
                
                Divider()
                    .frame(maxHeight: 1)
                    .overlay(Color(pc))
                    .padding(.horizontal)
                
                // Row 3
                HStack(spacing: 0) {
                    VStack {
                        Text(team.hc ?? "-").font(.callout).bold()
                        Text("Head Coach").font(.caption2).foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text(team.dLeague ?? "-").font(.callout).bold()
                        Text("D League Team").font(.caption2).foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: 15)
                .padding(.vertical, 14)
            }
            
            Divider()
                .padding(.horizontal)
            
            Button {
                withAnimation() {
                    showInfoDrawer.toggle()
                }
            } label: {
                Image(systemName: showInfoDrawer ? "chevron.compact.up" : "chevron.compact.down")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity)
            .tint(Color(pc))
            
        }
        .background(.ultraThinMaterial)
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
    }
    
    var statCard: some View {
        VStack {
            HStack {
                Menu {
                    Picker("Season", selection: $season) {
                        ForEach(seasons, id: \.self) {
                            Text($0)
                        }
                    }
                    .background(.clear)
                    .onChange(of: season) {
                        Task {
                            await getGames()
                        }
                    }
                } label: {
                    Text(season)
                        .font(.subheadline)
                        .tint(.secondary)
                }
                
                Divider()
                    .frame(maxWidth: 1)
                
                Menu {
                    Picker("Season Type", selection: $seasonType) {
                        ForEach(playerDataManager.seasonTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .background(.clear)
                    .onChange(of: seasonType) {
                        
                    }
                } label: {
                    Text(seasonType)
                        .font(.subheadline)
                        .tint(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 16, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 6)
            
            Divider()
                .frame(maxHeight: 2)
                .padding(.horizontal)
            
            HStack {
                Picker("View", selection: $selView) {
                    Text("Schedule").tag(0)
                    Text("Roster").tag(1)
//                    Text("Charts").tag(2)
                }
                .pickerStyle(.segmented)
                
                Button {
                    withAnimation() {
                        playerDataManager.showCharts.toggle()
                    }
                } label: {
                    Text("Charts")
                        .font(.system(size: 14)).fontWeight(.semibold)
                    Image(systemName: "chart.bar.xaxis")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(pc))
            }
            .padding(.horizontal)
            
            if selView == 0 {
                HStack {
                    Text("matchup").frame(maxWidth: .infinity)
                    Text("W/L").frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("H").foregroundStyle(.secondary)
                        Text("score")
                        Text("A").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: 20)
                .font(.callout)
                .fontWeight(.thin)
                .padding(.horizontal, 20)
                .padding(.top)
                
                List {
                    ForEach(gameStats) { game in
                        HStack {
                            HStack {
                                Text(game.homeAway == "Home" ? "vs" : "at")
                                
                                Image(uiImage: game.vsTeam.logo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 30, height: 30)
                                
                                Text(game.vsTeam.abbr)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Text(game.wl)
                                .frame(maxWidth: .infinity)
                                .bold()
                            
                            Text(game.score)
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .padding(.horizontal, 0)
                .scrollIndicators(.hidden)
                .listStyle(.plain)
            } else {
                List{
                    ForEach(roster, id: \.playerID) { player in
                        PlayerRowView(player: player, rowType: "roster")
                    }
                    .listRowBackground(Color.clear)
                }
                .padding(.horizontal, 0)
                .scrollIndicators(.hidden)
                .listStyle(.plain)
            }
        }
        .frame(maxHeight: .infinity)
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }
    
    func getTeamData() async {
        await vm.getTeamInfo(tID: team.teamID)
        await vm.getTeamDetails(tID: team.teamID)
        await vm.getTeamSchedule(tID: team.teamID, season: season)
        await vm.getTeamRoster(tID: team.teamID, season: season)

        if let t = Team.teamData.first(where: { $0.teamID == team.teamID }) {
            team = t
//            seasonStats = p.seasonStats ?? []
//            careerStats = p.careerStats ?? []
//            
//            for i in seasonStats.indices {
//                for k in seasonStats[i].seasonStats.keys {
//                    if !seasons.contains(k) {
//                        seasons.append(k)
//                    }
//                }
//            }
//            
//            seasons.sort()
//            seasons.reverse()
//            
//            season = seasons[0]
        }
        
//        await getGames()
    }
    
    func getGames() async {
//        gameStats = await playerDataManager.getPlayerGameStats(pID: p.playerID, season: season)
//        
//        if !gameStats.isEmpty {
//            let gs = gameStats[0]
//            
//            var h = StatTotals(gp: 0, gs: 0, min: Int(gs.min ?? 0), fgm: Int(gs.fgm ?? 0), fga: Int(gs.fga ?? 0), fg_pct: Double(Int(gs.fg_pct ?? 0)), fg3m: Int(gs.fg3m ?? 0), fg3a: Int(gs.fg3a ?? 0), fg3_pct: Double(Int(gs.fg3_pct ?? 0)), ftm: Int(gs.ftm ?? 0), fta: Int(gs.fta ?? 0), ft_pct: Double(Int(gs.ft_pct ?? 0)), oreb: Int(gs.oreb ?? 0), dreb: Int(gs.dreb ?? 0), reb: Int(gs.reb ?? 0), ast: Int(gs.ast ?? 0), stl: Int(gs.stl ?? 0), blk: Int(gs.blk ?? 0), tov: Int(gs.tov ?? 0), pf: Int(gs.pf ?? 0), pts: Int(gs.pts ?? 0))
    }
}

#Preview {
    TeamDetailView(team: Team.teamData[15]).environmentObject(PlayerDataManager()).environmentObject(TeamDataManager()).environmentObject(FavoritesManager())
}
