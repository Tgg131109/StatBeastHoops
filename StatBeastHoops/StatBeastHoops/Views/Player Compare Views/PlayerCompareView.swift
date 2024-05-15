//
//  PlayerCompareView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import SwiftUI
import Charts

struct PlayerCompareView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    @EnvironmentObject var favoritesManager : FavoritesManager
    
    @StateObject var cvm = CompareViewModel()
    
    @State private var season = "2023-24"
    @State private var dataReady = false
    @State private var activeTab = 1
    @State private var statSetType = 0
    
    @State private var data = [[GameStats]]()
    @State private var filteredData = [[GameStats]]()
    @State private var playerSeasonStats = [[PlayerSeasonStats]]()
    @State private var dataTotals = [StatTotals]()

    @State private var chartData = [[GameStat]]()
    @State private var chartSelection: Int?
    @State private var gameStats: [GameStatCompare] = []
    
    @State private var timeFrameFilter = 5
    @State private var splitBy = 0
    @State private var criteria = "PTS"
    
    var p1ID : Int {
        return cvm.p1.playerID
    }
    
    var p2ID : Int {
        return cvm.p2.playerID
    }
    
    var t1 : Team {
        if let team = Team.teamData.first(where: { $0.teamID == cvm.p1.teamID }) {
            return team
        } else {
            return Team.teamData[30]
        }
    }
    
    var t2 : Team {
        if let team = Team.teamData.first(where: { $0.teamID == cvm.p2.teamID }) {
            return team
        } else {
            return Team.teamData[30]
        }
    }
    
    var gamesPlayed : [Double] {
        var gp = [Double]()
        
        if let g = cvm.statCompare.first(where: { $0.stat == "GP" }) {
            gp.append(Double(g.value1) ?? 0)
            gp.append(Double(g.value2) ?? 0)
        }
        
        return gp
    }
    
    var statSet : [StatCompare] {
        return statSetType == 0 ? cvm.oppOnCourt : cvm.statCompare
    }
    
    var matchup: Matchup {
        return Matchup(p1: cvm.p1, p2: cvm.p2)
    }
    
    var isFav : Bool {
        return favoritesManager.contains(matchup)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                matchupCard
                
                HStack {
                    if activeTab == 2 {
                        Image(systemName: "arrowshape.backward")
                    }
                    
                    Text(activeTab == 1 ? "Swipe for charts" : "Swipe for stats")
                        
                    
                    if activeTab == 1 {
                        Image(systemName: "arrowshape.forward")
                    }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
                
                TabView(selection: $activeTab.animation()) {
                    VStack {
                        statsCard
                        winnerCard
                    }
                    .padding(.horizontal)
                    .tag(1)
                    
                    chartCard
                        .tag(2)
                        .onChange(of: cvm.updateCharts) {
                            if cvm.updateCharts {
                                getCharts()
                                cvm.updateCharts = false
                            }
                        }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Compare Players").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            withAnimation {
                                if isFav {
                                    favoritesManager.remove(matchup)
                                } else {
                                    favoritesManager.add(matchup)
                                }
                            }
                        } label: {
                            Image(systemName: isFav ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                        }
                        
                        Button {
                            cvm.showCompareSetup = true
                            statSetType = 0
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $cvm.showCompareSetup) {
            CompareSetupView(cvm: cvm, dataReady: $dataReady)
        }
        .onAppear(perform: {
            // Comment this entire onAppear section to prevent preview from crashing while developing.
            if cvm.p1.playerID == cvm.p2.playerID {
                cvm.p1 = playerDataManager.ptsLeaders[0]
                cvm.p2 = playerDataManager.ptsLeaders[1]
            }
            
            Task {
                await getMatchupData()
                dataReady = true
            }
        })
    }
    
    var matchupCard: some View {
        VStack {
            ZStack {
                // Player backgrounds
                Group {
                    Image(uiImage: t1.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(0.5)
                        .padding(.leading, -200)
                        .background(.regularMaterial)
                        .overlay(Color(t1.priColor).opacity(0.8))
                        .overlay(Image(uiImage: t2.logo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(0.5)
                            .padding(.trailing, -200)
                            .background(.regularMaterial)
                            .overlay(Color(t2.priColor).opacity(0.8))
                            .clipShape(Triangle()))
                }
                .frame(maxWidth: .infinity, maxHeight: 120)
                .clipped()
                
                Text("VS").font(.system(size: 60)).fontWeight(.black).foregroundStyle(.ultraThinMaterial).frame(maxHeight: 100)
                
                // Player images
                HStack {
                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p1ID).png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(uiImage: t1.logo).resizable().aspectRatio(contentMode: .fill).opacity(0.4)
                    }
                    .padding(.top, 6)
                    .frame(maxWidth: .infinity, maxHeight: 120, alignment: .leading)
                    
                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p2ID).png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(uiImage: t2.logo).resizable().aspectRatio(contentMode: .fill).opacity(0.4)
                    }
                    .padding(.top, 6)
                    .frame(maxWidth: .infinity, maxHeight: 120, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, maxHeight: 120)
            }
            
            // Player names
            HStack {
                HStack {
                    Circle().fill(Color(t1.priColor)).frame(width: 10, height: 10)
                    Text("\(cvm.p1.firstName) \(cvm.p1.lastName)").font(.caption).bold()
                    Text(cvm.p1.team.abbr).font(.caption).foregroundStyle(.tertiary)
                }.padding(.leading)
                
                Spacer()
                
                HStack {
                    Text(cvm.p2.team.abbr).font(.caption).foregroundStyle(.tertiary)
                    Text("\(cvm.p2.firstName) \(cvm.p2.lastName)").font(.caption).bold()
                    Rectangle().fill(Color(t2.priColor)).frame(width: 10, height: 10)
                }.padding(.trailing)
            }
            .padding(.top, 2)
            .padding(.bottom, 10)
        }
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding([.top, .horizontal])
    }
    
    var statsCard: some View {
        VStack {
            let totalStats = ["GP", "W", "L"]
            
            Picker("Stat Set", selection: $statSetType.animation()) {
                Text("Head-to-Head").tag(0)
                Text("Overall").tag(1)
            }
            .pickerStyle(.segmented)
            .padding([.top, .horizontal])
            
            Text("2023-24 Regular Season Stats")
                .font(.caption)
                .foregroundStyle(.tertiary)
            
            if !dataReady {
                ProgressView().padding().controlSize(.large)
            } else {
                List {
                    ForEach(statSet, id: \.id) { stat in
                        ZStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stat.value1)
                                        .font(.title2.bold())
                                    
                                    if statSetType == 1 && !stat.stat.contains("PCT") && !totalStats.contains(stat.stat) {
                                        Text(getPerGameStat(val: stat.value1, i: 0)).font(.caption2)
                                    }
                                }
                                
                                if statSetType == 0 {
                                    if let off = cvm.oppOffCourt.first(where: { $0.stat == stat.stat })?.value1 {
                                        Text(off).font(.footnote).foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer ()
                                
                                if statSetType == 0 {
                                    if let off = cvm.oppOffCourt.first(where: { $0.stat == stat.stat })?.value2 {
                                        Text(off).font(.footnote).foregroundStyle(.secondary)
                                    }
                                }
                                
                                VStack(alignment: .trailing) {
                                    Text(stat.value2)
                                        .font(.title2.bold())
                                    
                                    if statSetType == 1 && !stat.stat.contains("PCT") && !totalStats.contains(stat.stat) {
                                        Text(getPerGameStat(val: stat.value2, i: 1)).font(.caption2)
                                    }
                                }
                            }
                            
                            Text(getStatStr(stat: stat.stat))
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollIndicators(.hidden)
                .listStyle(.plain)
            }
            
            HStack {
                Text(statSetType == 0 ? "opponent on court" : "")
                    .font(.caption)
                    .bold()
                
                Text(statSetType == 0 ? "opponent off court" : "")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 6)
            .padding(.top, 2)
        }
        .frame(maxHeight: .infinity)
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }
    
    var winnerCard: some View {
        ZStack {
            if !dataReady {
                ProgressView().padding().controlSize(.large)
            } else {
                let w = getWinner()
                let t = w == 1 ? t1 : t2
                let pID = w == 1 ? p1ID : p2ID
                
                // Player backgrounds
                Group {
                    Image(uiImage: t.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(0.5)
                        .padding(.leading, -200)
                        .background(.regularMaterial)
                        .overlay(Color(t.priColor).opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
                .clipped()
                
                VStack {
                    // Player image
                    HStack {
                        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(pID).png")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Image(uiImage: t1.logo).resizable().aspectRatio(contentMode: .fill).opacity(0.4)
                        }
                        .padding(.top, 6)
                        
                        let pn = w == 1 ? "\(cvm.p1.firstName) \(cvm.p1.lastName)" : "\(cvm.p2.firstName) \(cvm.p2.lastName)"
                        
                        Text("Advantage \(pn)").foregroundStyle(.ultraThickMaterial).bold().padding(.leading, -20).padding(.trailing)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.bottom)
    }
    
    var chartCard: some View {
        VStack {
            Picker("Data Period", selection: $timeFrameFilter) {
                Text("Last 5").tag(5)
                Text("Last 10").tag(10)
                Text("Last 15").tag(15)
                Text("Season").tag(0)
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: timeFrameFilter, {
                withAnimation {
                    filterData()
                }
            })
            
            if !dataReady {
                ProgressView().padding().controlSize(.large)
            } else {
                if splitBy == 0 {
                    Chart {
                        ForEach(chartData[0], id: \.id) { data in
                            BarMark(
                                x: .value("X", data.sort),
                                y: .value("Y", data.val)
                            )
                            .foregroundStyle(
                                    .linearGradient(
                                        colors: [data.color, data.color.opacity(0.2)], startPoint: .top, endPoint: .bottom
                                    )
                                )
                            .annotation(position: .top) {
                                Group {
                                    HStack {
                                        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(data.playerID).png")) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            Image(uiImage: data.player?.team.logo ?? Team.teamData[30].logo)
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(0.4)
                                        }
                                        .frame(maxHeight: 30)
                                        
                                        Text(criteria.contains("PCT") ? String(format: "%.1f", (Double(data.val) * 100)) : String(Int(data.val)))
                                            .font(.callout)
                                            .bold()
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    .chartYAxis(.hidden)
                } else {
                    ZStack {
                        VStack {
                            ForEach(chartData.indices, id: \.self) { i in
                                Chart {
                                    let linearGradient = LinearGradient(gradient: Gradient(colors: [chartData[i][0].color.opacity(0.4), chartData[i][0].color.opacity(0)]), startPoint: .top, endPoint: .bottom)
                                    
                                    ForEach(chartData[i], id: \.id) { data in
                                        LineMark(
                                            x: .value("Stat", Int(data.sort) ?? 0),
                                            y: .value("Value", data.val),
                                            series: .value("Player", data.playerID)
                                        )
                                        .symbol(i == 0 ? .circle : .square)
                                        .foregroundStyle(data.color)
                                        .interpolationMethod(.catmullRom)
                                        
                                        if let chartSelection {
                                            RuleMark(x: .value("Stat", chartSelection))
                                                .foregroundStyle(.gray.opacity(0.2))
                                                .annotation( position: i == 0 ? .top : .bottom, overflowResolution: .init(x: .fit, y: .fit)) {
                                                    RuleMarkContentView(val: chartData[i][chartSelection].val, criteria: criteria, matchup: chartData[i][chartSelection].matchup, gameDate: chartData[i][chartSelection].gameDate)
                                                }
                                        }
                                        
                                        AreaMark(
                                            x: .value("Stat", Int(data.sort) ?? 0),
                                            y: .value("Value", data.val)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(linearGradient)
                                    }
                                }
                            }
                            .chartXAxis(.hidden)
                            .chartYAxis(.hidden)
                            .chartXSelection(value: $chartSelection)
                        }
                        
                        if chartData.count > 1 {
                            let totalChg1 = cvm.getTotalChange(chartData: chartData[0])
                            let totalChg2 = cvm.getTotalChange(chartData: chartData[1])
                            
                            HStack {
                                HStack {
                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p1ID).png")) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Image(uiImage: t1.logo)
                                            .resizable()
                                            .scaledToFit()
                                            .opacity(0.4)
                                    }
                                    .frame(maxHeight: 30)
                                    
                                    Image(systemName: cvm.getChangeImage(pc: totalChg1))
                                        .foregroundStyle(cvm.getChangeTint(pc: totalChg1))
                                    
                                    Text("\(String(format: "%.1f", (totalChg1)))")
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider()
                                    .foregroundStyle(.primary)
                                    .frame(maxHeight: 30)
                                
                                HStack {
                                    Image(systemName: cvm.getChangeImage(pc: totalChg2))
                                        .foregroundStyle(cvm.getChangeTint(pc: totalChg2))
                                    
                                    Text("\(String(format: "%.1f", (totalChg2)))")
                                    
                                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p2ID).png")) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Image(uiImage: t2.logo)
                                            .resizable()
                                            .scaledToFit()
                                            .opacity(0.4)
                                    }
                                    .frame(maxHeight: 30)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .bold()
                            .padding(6)
                            .background(.ultraThinMaterial.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 16))
                            .shadow(radius: 10)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            
            HStack {
                Picker("Criteria", selection: $criteria) {
                    ForEach(cvm.compareCategories, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .background(.regularMaterial).clipShape(.capsule)
                .onChange(of: criteria) {
                    withAnimation {
                        getCharts()
                    }
                }
                
                Picker("Data Splits", selection: $splitBy.animation()) {
                    Text("Traditional").tag(0)
                    Text("Trends").tag(1)
                }
                .pickerStyle(.segmented)
                .onChange(of: splitBy, {
                    getCharts()
                })
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
        .overlay(content: { if !dataReady { ShimmerEffectBox() } })
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding([.bottom, .horizontal])
    }
    
    func getMatchupData() async {
        dataReady = false
        
        await cvm.compareStats(p1ID: "\(cvm.p1.playerID)", p2ID: "\(cvm.p2.playerID)", criteria: criteria)
        
        data = [await playerDataManager.getPlayerGameStats(pID: cvm.p1.playerID, season: season), await playerDataManager.getPlayerGameStats(pID: cvm.p2.playerID, season: season)]
        
        filterData()
    }
    
    func filterData() {
        dataTotals.removeAll()
        filteredData = [timeFrameFilter != 0 ? data[0].suffix(timeFrameFilter) : data[0], timeFrameFilter != 0 ? data[1].suffix(timeFrameFilter) : data[1]]
        
        for i in filteredData.indices {
            let min = filteredData[i].reduce(0, {$0 + Int(($1.min ?? 0))})
            let fgm = filteredData[i].reduce(0, {$0 + Int(($1.fgm ?? 0))})
            let fga = filteredData[i].reduce(0, {$0 + Int(($1.fga ?? 0))})
            let fg_pct = (Double(fgm)/Double(fga) * 100).formatted(.number.precision(.fractionLength(1)))
            let fg3m = filteredData[i].reduce(0, {$0 + Int(($1.fg3m ?? 0))})
            let fg3a = filteredData[i].reduce(0, {$0 + Int(($1.fg3a ?? 0))})
            let fg3_pct = (Double(fg3m)/Double(fg3a) * 100).formatted(.number.precision(.fractionLength(1)))
            let ftm = filteredData[i].reduce(0, {$0 + Int(($1.ftm ?? 0))})
            let fta = filteredData[i].reduce(0, {$0 + Int(($1.fta ?? 0))})
            let ft_pct = (Double(ftm)/Double(fta) * 100).formatted(.number.precision(.fractionLength(1)))
            let oreb = filteredData[i].reduce(0, {$0 + Int(($1.oreb ?? 0))})
            let dreb = filteredData[i].reduce(0, {$0 + Int(($1.dreb ?? 0))})
            let reb = filteredData[i].reduce(0, {$0 + Int(($1.reb ?? 0))})
            let ast = filteredData[i].reduce(0, {$0 + Int(($1.ast ?? 0))})
            let stl = filteredData[i].reduce(0, {$0 + Int(($1.stl ?? 0))})
            let blk = filteredData[i].reduce(0, {$0 + Int(($1.blk ?? 0))})
            let tov = filteredData[i].reduce(0, {$0 + Int(($1.tov ?? 0))})
            let pf = filteredData[i].reduce(0, {$0 + Int(($1.pf ?? 0))})
            let pts = filteredData[i].reduce(0, {$0 + Int(($1.min ?? 0))})
            let pts1 = ftm
            let pts3 = fg3m * 3
            let pts2 = pts - (pts1 + pts3)
            let def = stl + blk
            
            dataTotals.append(StatTotals(age: def, gp: pts2, gs: pts3, min: min, fgm: fgm, fga: fga, fg_pct: Double(fg_pct) ?? 0, fg3m: fg3m, fg3a: fg3a, fg3_pct: Double(fg3_pct) ?? 0, ftm: ftm, fta: fta, ft_pct: Double(ft_pct) ?? 0, oreb: oreb, dreb: dreb, reb: reb, ast: ast, stl: stl, blk: blk, tov: tov, pf: pf, pts: pts))
        }
        
        getCharts()
    }
    
    func getCharts() {
        // bar graph data
        if splitBy == 0 {
            let totals = [getChartY(criterion: criteria, playerIndex: 0), getChartY(criterion: criteria, playerIndex: 1)]
            
            chartData = [[GameStat(gameID: "1", gameDate: "", matchup: "", sort: cvm.p1.firstName, val: totals[0], player: cvm.p1, color: Color(cvm.p1.team.priColor)), GameStat(gameID: "2", gameDate: "", matchup: "", sort: cvm.p2.firstName, val: totals[1], player: cvm.p2, color: Color(cvm.p2.team.priColor))]]
        // line chart data
        } else {
            let values = [getChartY(criterion: criteria, dataSet: filteredData[0]), getChartY(criterion: criteria, dataSet: filteredData[1])]
            
            var cd1: [GameStat] = []
            var cd2: [GameStat] = []
            
            for i in filteredData[0].indices {
                cd1.append(GameStat(gameID: filteredData[0][i].gameID, gameDate: filteredData[0][i].gameDate, matchup: filteredData[0][i].matchup, sort: "\(i)", val: values[0][i], player: cvm.p1, color: Color(cvm.p1.team.priColor)))
            }
            
            for i in filteredData[1].indices {
                cd2.append(GameStat(gameID: filteredData[1][i].gameID, gameDate: filteredData[1][i].gameDate, matchup: filteredData[1][i].matchup, sort: "\(i)", val: values[1][i], player: cvm.p2, color: Color(cvm.p2.team.priColor)))
            }
            
            chartData = [cd1, cd2]
        }
    }
    
    func getChartY(criterion: String, dataSet: [GameStats]) -> [Double] {
        var y : [Double] = []
        
        // get y
        switch criterion {
        case "MIN":
            y = dataSet.map { $0.min ?? 0 }
        case "FGM":
            y = dataSet.map { $0.fgm ?? 0 }
        case "FGA":
            y = dataSet.map { $0.fga ?? 0 }
        case "FG%":
            y = dataSet.map { $0.fg_pct ?? 0 }
        case "FG3M":
            y = dataSet.map { $0.fg3m ?? 0 }
        case "FG3A":
            y = dataSet.map { $0.fg3a ?? 0 }
        case "FG3%":
            y = dataSet.map { $0.fg3_pct ?? 0 }
        case "FTM":
            y = dataSet.map { $0.ftm ?? 0 }
        case "FTA":
            y = dataSet.map { $0.fta ?? 0 }
        case "FT%":
            y = dataSet.map { $0.ft_pct ?? 0 }
        case "OREB":
            y = dataSet.map { $0.oreb ?? 0 }
        case "DREB":
            y = dataSet.map { $0.dreb ?? 0 }
        case "REB":
            y = dataSet.map { $0.reb ?? 0 }
        case "AST":
            y = dataSet.map { $0.ast ?? 0 }
        case "STL":
            y = dataSet.map { $0.stl ?? 0 }
        case "BLK":
            y = dataSet.map { $0.blk ?? 0 }
        case "TOV":
            y = dataSet.map { $0.tov ?? 0 }
        case "PF":
            y = dataSet.map { $0.pf ?? 0 }
        case "+/-":
            y = dataSet.map { $0.pm ?? 0 }
        case "FP":
            y = dataSet.map { $0.fantasyPts ?? 0 }
        case "DD2":
            y = dataSet.map { $0.DD2 ?? 0 }
        case "TD3":
            y = dataSet.map { $0.TD3 ?? 0 }
        default:
            y = dataSet.map { $0.pts ?? 0 }
        }
        
        return y
    }
    
    func getChartY(criterion: String, playerIndex: Int) -> Double {
        var y : Double = 0
        
        if playerDataManager.totalCategories.contains(criterion) {
            let totals = dataTotals[playerIndex]
            
            switch criterion {
            case "GP":
                y = Double(totals.gp)
            case "GS":
                y = Double(totals.gs)
            case "MIN":
                y = Double(totals.min)
            case "FGM":
                y = Double(totals.fgm)
            case "FGA":
                y = Double(totals.fga)
            case "FG%":
                y = totals.fg_pct
            case "FG3M":
                y = Double(totals.fg3m)
            case "FG3A":
                y = Double(totals.fg3a)
            case "FG3%":
                y = totals.fg3_pct
            case "FTM":
                y = Double(totals.ftm)
            case "FTA":
                y = Double(totals.fta)
            case "FT%":
                y = totals.ft_pct
            case "OREB":
                y = Double(totals.oreb)
            case "DREB":
                y = Double(totals.dreb)
            case "REB":
                y = Double(totals.reb)
            case "AST":
                y = Double(totals.ast)
            case "STL":
                y = Double(totals.stl)
            case "BLK":
                y = Double(totals.blk)
            case "TOV":
                y = Double(totals.tov)
            case "PF":
                y = Double(totals.pf)
            default:
                y = Double(totals.pts)
            }
        } else {
            let dataSet = filteredData[playerIndex]
            
            switch criterion {
            case "+/-":
                y = dataSet.reduce(0, {$0 + Double(($1.pm ?? 0))})
            case "FP":
                y = dataSet.reduce(0, {$0 + Double(($1.fantasyPts ?? 0))})
            case "DD2":
                y = dataSet.reduce(0, {$0 + Double(($1.DD2 ?? 0))})
            case "TD3":
                y = dataSet.reduce(0, {$0 + Double(($1.TD3 ?? 0))})
            default:
                break
            }
        }
        
        return y
    }
    
    func getPerGameStat(val: String, i: Int) -> String {
        let pg = String(format: "%.1f", (Double(val) ?? 0) / gamesPlayed[i])
        
        return "\(pg) per game"
    }
    
    func getStatStr(stat: String) -> String {
        var str = stat
        
        if stat.contains("PCT") {
            str = "\(stat.components(separatedBy: "_")[0]) %"
        }
        
        if stat == "PLUS_MINUS" {
            str = "+/-"
        }
        
        if stat == "NBA_FANTASY_PTS" {
            str = "Fanstasy PTS"
        }
        
        return str
    }
    
    func getWinner() -> Int {
        var pts1 = 0.0
        var pts2 = 0.0
        
        let sigStats = ["FG_PCT", "TOV", "OREB", "FTA"]
        let exclStats = ["GP", "W", "L", "W_PCT", "MIN"]
        
        for stat1 in cvm.onOffCourtP1 {
            for stat2 in cvm.onOffCourtP2 {
                if stat1.stat == stat2.stat {
                    if stat1.stat == "TOV" {
                        if stat1.value1 < stat2.value1 {
                            pts1 += 1
                        } else {
                            pts2 += 1
                        }
                    } else if sigStats.contains(stat1.stat) {
                        if stat1.value1 > stat2.value1 {
                            pts1 += 1.2
                        } else {
                            pts2 += 1.2
                        }
                    } else if !(exclStats.contains(stat1.stat)) {
                        if stat1.value1 > stat2.value1 {
                            pts1 += 1
                        } else {
                            pts2 += 1
                        }
                    }
                }
            }
        }
        
        // Significant Stats (FG_PCT, TOV, OREB, FTA)
        return pts1 > pts2 ? 1 : 2
    }
}

// This is to make a rounded rectangle with specific sides rounded. Not needed right now, but may be handy later.
//extension View {
//    // Function to add rounded corners to any SwiftUI view
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        // Using the clipShape modifier to apply the rounded corner shape
//        clipShape( RoundedCorner(radius: radius, corners: corners) )
//    }
//}
//
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//    
//    // Creating a UIBezierPath to draw the rounded corner shape
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect,
//                                byRoundingCorners: corners,
//                                cornerRadii: CGSize(width: radius, height: radius))
//        // Converting the UIBezierPath to a SwiftUI Path
//        return Path(path.cgPath)
//    }
//}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX * 0.2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.8, y: rect.maxY))
        return path
    }
}

struct Matchup: Decodable, Encodable, Identifiable {
    var id = UUID()
    
    var p1: Player
    var p2: Player
}
#Preview {
    PlayerCompareView().environmentObject(DataManager()).environmentObject(PlayerCompareViewModel()).environmentObject(PlayerDataManager()).environmentObject(FavoritesManager())
}
