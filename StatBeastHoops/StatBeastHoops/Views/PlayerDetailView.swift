//
//  PlayerDetailView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/12/24.
//

import SwiftUI
import Charts
//import Foundation

struct PlayerDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    @State private var seasons = [String]()
    @State private var season = "2023-24"
    @State private var seasonType = "Regular Season"
    @State private var selView = 0
    @State private var dataReady = false
    
    @State private var seasonStats = [PlayerSeasonStats]()
    @State private var careerStats = [PlayerCareerStats]()
    @State private var gameStats : [GameStats] = []
    @State private var highs : [String] = []
    @State private var showInfoDrawer = true
    @State private var showCharts = false
    
    @State var p : Player
    
    var team : Team {
        return p.team
    }
    
    var pc : UIColor {
        return team.priColor
    }
    
    var selectedStats: [StatTotals] {
        if let ss = seasonStats.first(where: { $0.seasonType == seasonType })?.seasonStats[season] {
            return [ss]
        } else {
            return []
        }
    }
    
    var selectedStatsRanked: [Rankings] {
        if let sr = seasonStats.first(where: { $0.seasonType == seasonType })?.seasonRankings[season] {
            return [sr]
        } else {
            return []
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerCard
            
            headerStatRow
            
            VStack {
                playerInfoDrawer
                
                statCard
            }
            .toolbar {
                if !playerDataManager.showCharts {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("", systemImage: "chevron.backward.circle.fill") {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .tint(.white.opacity(0.8))
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text(team.homeTown)
                                .bold()
                                .padding(.trailing, -10)
                            
                            Image(uiImage: team.logo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, alignment: .center)
                            
                            Text(team.teamName)
                                .bold()
                                .padding(.leading, -10)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        FollowButton(p: p, t: nil)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .toolbarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
        .overlay(content: {if playerDataManager.showCharts { ChartView(p: p, selectedStats: selectedStats, data: gameStats).background(.ultraThinMaterial) } })
        .onAppear(perform: {   Task{
            await getPlayerData()
            dataReady = true
        } })
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
                        // Player info bar
                        VStack(alignment: .leading) {
                            Text(p.firstName.uppercased())
                                .padding(.bottom, -10)
                            
                            Text(p.lastName.uppercased())
                                .font(.title2)
                                .fontWeight(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(team.abbr).bold()
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
                                
                                Divider().frame(maxWidth: 2)
                                    .overlay(.white)
                                    .opacity(0.5)
                                
                                Text("#\(p.jersey ?? "-")")
                                    .bold().foregroundStyle(.white)
                                    .opacity(0.8)
                                
                                Divider().frame(maxWidth: 2)
                                    .overlay(.white)
                                    .opacity(0.5)
                                
                                Text(p.position ?? "-")
                                    .bold()
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
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
                
                // Player image
                AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p.playerID).png")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(uiImage: team.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 160)
                        .opacity(0.4)
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity, maxHeight: 160, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .frame(maxHeight: 150)
    }
    
    var headerStatRow: some View {
        HStack(spacing: 0) {
            if !selectedStats.isEmpty {
                VStack {
                    let s = String(format: "%.1f", (Double((selectedStats[0].pts)/(selectedStats[0].gp))))
                    
                    Text(s).font(.title3).bold()
                    Text("PPG").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .border(.regularMaterial)
                
                VStack {
                    let s = String(format: "%.1f", (Double((selectedStats[0].reb)/(selectedStats[0].gp))))
                    
                    Text(s).font(.title3).bold()
                    Text("RPG").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .border(.regularMaterial)
                
                VStack {
                    let s = String(format: "%.1f", (Double((selectedStats[0].ast)/(selectedStats[0].gp))))
                    
                    Text(s).font(.title3).bold()
                    Text("APG").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .border(.regularMaterial)
                
                VStack {
                    Text("\(Int(selectedStats[0].gp))").font(.title3).bold()
                    Text("GP").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .border(.regularMaterial)
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
        .background(Color(p.team.priColor))
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
    }
    
    var playerInfoDrawer: some View {
        VStack(spacing: 0) {
            if showInfoDrawer {
                // Row 1
                HStack(spacing: 16) {
                    VStack {
                        Text("\(p.ht)").font(.callout).bold()
                        Text("Ht").font(.caption2).foregroundStyle(.tertiary)
                    }
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text("\(p.wt)").font(.callout).bold()
                        Text("Wt").font(.caption2).foregroundStyle(.tertiary)
                    }
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text(p.birthDate!).font(.callout).bold()
                        Text("Birthday").font(.caption2).foregroundStyle(.tertiary)
                    }
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text("\(p.age!)").font(.callout).bold()
                        Text("Age").font(.caption2).foregroundStyle(.tertiary)
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
                        Text("\(p.draft)").font(.callout).bold()
                        Text("Draft").font(.caption2).foregroundStyle(.tertiary)
                    }
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text("\(p.exp)").font(.callout).bold()
                        Text("Experience").font(.caption2).foregroundStyle(.tertiary)
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
                        Text("\(p.college ?? "-")").font(.callout).bold()
                        Text("School").font(.caption2).foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(maxWidth: 1)
                        .padding(.vertical, -4)
                    
                    VStack {
                        Text("\(p.country ?? "-")").font(.callout).bold()
                        Text("Country").font(.caption2).foregroundStyle(.tertiary)
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
                    Text("Overall").tag(0)
                    Text("Per Game").tag(1)
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
            
            // OK, so three way segcontroller (Overall, Per Game, Charts)
            // Overall - List(category | avg | total | high | rank). Still need to grab highs and rank.
            // Per Game - List(team w/image | date | [stats])
            // Make each item open to game summary detail view (should be similar to Overall list)
            // Charts - charts obviously. Have options for different chart types.
            
            if selView == 0 {
                HStack {
                    Text("").frame(maxWidth: .infinity)
                    Divider().overlay(.ultraThinMaterial)
                    Text("total").frame(maxWidth: .infinity)
                    Text("avg").frame(maxWidth: .infinity)
                    Text("high").frame(maxWidth: .infinity)
                    Text("rank").frame(maxWidth: .infinity)
                }
                .frame(maxHeight: 20)
                .font(.callout)
                .fontWeight(.thin)
                .padding(.horizontal, 20)
                .padding(.top)
                
                List {
                    // Test headers for lining up header hstack.
                    //                            HStack {
                    //                                Text("").frame(maxWidth: .infinity)
                    //                                Divider().overlay(.ultraThinMaterial)
                    //                                Text("totals").frame(maxWidth: .infinity)
                    //                                Text("avg").frame(maxWidth: .infinity)
                    //                                Text("high").frame(maxWidth: .infinity)
                    //                                Text("rank").frame(maxWidth: .infinity)
                    //                            }
                    //                            .font(.callout)
                    //                            .bold()
                    //                            .listRowBackground(Color.clear)
                    
                    ForEach(playerDataManager.totalCategories.indices, id: \.self) { i in
                        HStack {
                            Text(playerDataManager.totalCategories[i])
                                .font(.callout)
                                .fontWeight(.thin)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider().overlay(.ultraThinMaterial)
                            
                            if !selectedStats.isEmpty {
                                Text(selectedStats[0].all[i])
                                    .frame(maxWidth: .infinity)
                                    .bold()
                                
                                Text(selectedStats[0].avg[i])
                                    .frame(maxWidth: .infinity)
                                    .bold()
                                
                                Text(highs.isEmpty ? "-" : highs[i])
                                    .frame(maxWidth: .infinity)
                                    .bold()
//                                    .overlay(content: { if highs.isEmpty { ShimmerEffectBox() } })
                                
                                Text(!selectedStatsRanked.isEmpty ? selectedStatsRanked[0].all[i] : "-")
                                    .frame(maxWidth: .infinity)
                                    .bold()
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .padding(.horizontal, 0)
                .scrollIndicators(.hidden)
                .listStyle(.plain)
            } else {
                HStack {
                    Text("matchup").frame(maxWidth: .infinity)
//                    Divider().overlay(.ultraThinMaterial)
                    Text("points").frame(maxWidth: .infinity)
                    Text("fantasy").frame(maxWidth: .infinity)
//                    Text("high").frame(maxWidth: .infinity)
//                    Text("rank").frame(maxWidth: .infinity)
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
                            
                            Text("\(Int(game.pts ?? 0))")
                                .frame(maxWidth: .infinity)
                                .bold()
                            
                            Text("\(String(format: "%.1f", (game.fantasyPts ?? 0)))")
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                        .listRowBackground(Color.clear)
                    }
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
    
    func getPlayerData() async {
        await playerDataManager.getPlayerInfo(pID: p.playerID)
        await playerDataManager.getPlayerStatTotals(player: p)
        
        if let player = p.team.roster?.first(where: { $0.playerID == p.playerID }) {
            p = player
            seasonStats = p.seasonStats ?? []
            careerStats = p.careerStats ?? []
            
            for i in seasonStats.indices {
                for k in seasonStats[i].seasonStats.keys {
                    if !seasons.contains(k) {
                        seasons.append(k)
                    }
                }
            }
            
            seasons.sort()
            seasons.reverse()
            
            season = seasons[0]
        }
        
        await getGames()
    }
    
    func getGames() async {
        gameStats = await playerDataManager.getPlayerGameStats(pID: p.playerID, season: season)
        
        if !gameStats.isEmpty {
            let gs = gameStats[0]
            
            var h = StatTotals(gp: 0, gs: 0, min: Int(gs.min ?? 0), fgm: Int(gs.fgm ?? 0), fga: Int(gs.fga ?? 0), fg_pct: Double(Int(gs.fg_pct ?? 0)), fg3m: Int(gs.fg3m ?? 0), fg3a: Int(gs.fg3a ?? 0), fg3_pct: Double(Int(gs.fg3_pct ?? 0)), ftm: Int(gs.ftm ?? 0), fta: Int(gs.fta ?? 0), ft_pct: Double(Int(gs.ft_pct ?? 0)), oreb: Int(gs.oreb ?? 0), dreb: Int(gs.dreb ?? 0), reb: Int(gs.reb ?? 0), ast: Int(gs.ast ?? 0), stl: Int(gs.stl ?? 0), blk: Int(gs.blk ?? 0), tov: Int(gs.tov ?? 0), pf: Int(gs.pf ?? 0), pts: Int(gs.pts ?? 0))
            
            // Calculate highs
            for game in gameStats {
                if Int(game.min ?? 0) > h.min {
                    h.min = Int(game.min ?? 0)
                }
                
                if Int(game.fgm ?? 0) > h.fgm {
                    h.fgm = Int(game.fgm ?? 0)
                }
                
                if Int(game.fga ?? 0) > h.fga {
                    h.fga = Int(game.fga ?? 0)
                }
                
                if Double(game.fg_pct ?? 0) > h.fg_pct {
                    h.fg_pct = Double(game.fg_pct ?? 0)
                }
                
                if Int(game.fg3m ?? 0) > h.fg3m {
                    h.fg3m = Int(game.fg3m ?? 0)
                }
                
                if Int(game.fg3a ?? 0) > h.fg3a {
                    h.fg3a = Int(game.fg3a ?? 0)
                }
                
                if Double(game.fg3_pct ?? 0) > h.fg3_pct {
                    h.fg3_pct = Double(game.fg3_pct ?? 0)
                }
                
                if Int(game.ftm ?? 0) > h.ftm {
                    h.ftm = Int(game.ftm ?? 0)
                }
                
                if Int(game.fta ?? 0) > h.fta {
                    h.fta = Int(game.fta ?? 0)
                }
                
                if Double(game.ft_pct ?? 0) > h.ft_pct {
                    h.ft_pct = Double(game.ft_pct ?? 0)
                }
                
                if Int(game.oreb ?? 0) > h.oreb {
                    h.oreb = Int(game.oreb ?? 0)
                }
                
                if Int(game.dreb ?? 0) > h.dreb {
                    h.dreb = Int(game.dreb ?? 0)
                }
                
                if Int(game.reb ?? 0) > h.reb {
                    h.reb = Int(game.reb ?? 0)
                }
                
                if Int(game.ast ?? 0) > h.ast {
                    h.ast = Int(game.ast ?? 0)
                }
                
                if Int(game.stl ?? 0) > h.stl {
                    h.stl = Int(game.stl ?? 0)
                }
                
                if Int(game.blk ?? 0) > h.blk {
                    h.blk = Int(game.blk ?? 0)
                }
                
                if Int(game.tov ?? 0) > h.tov {
                    h.tov = Int(game.tov ?? 0)
                }
                
                if Int(game.pf ?? 0) > h.pf {
                    h.pf = Int(game.pf ?? 0)
                }
                
                if Int(game.pts ?? 0) > h.pts {
                    h.pts = Int(game.pts ?? 0)
                }
            }
            
            highs = ["-", "-", "\(h.min)", "\(h.fgm)", "\(h.fga)", String(format: "%.1f", (Double(h.fg_pct)) * 100), "\(h.fg3m)", "\(h.fg3a)", String(format: "%.1f", (Double(h.fg3_pct)) * 100), "\(h.ftm)", "\(h.fta)", String(format: "%.1f", (Double(h.ft_pct)) * 100), "\(h.oreb)", "\(h.dreb)", "\(h.reb)", "\(h.ast)", "\(h.stl)", "\(h.blk)", "\(h.tov)", "\(h.pf)", "\(h.pts)"]
        }
    }
}

extension View {
    // Function to add rounded corners to any SwiftUI view
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        // Using the clipShape modifier to apply the rounded corner shape
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    // Creating a UIBezierPath to draw the rounded corner shape
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        // Converting the UIBezierPath to a SwiftUI Path
        return Path(path.cgPath)
    }
}

#Preview {
    PlayerDetailView(p: Player.demoPlayer).environmentObject(PlayerDataManager())
}
