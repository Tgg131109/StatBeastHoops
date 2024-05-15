//
//  ChartView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/20/24.
//

import SwiftUI
import Charts

struct ChartView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    @StateObject var cvm = CompareViewModel()
    
    @State var p: Player
    @State var selectedStats : [StatTotals]
    @State var data : [GameStats]
    
    @State private var filteredData = [GameStats]()
    @State private var dataTotals : [StatTotals] = []
    @State private var chartData = [GameStat]()
    @State private var chartSelection: Int?
    @State private var selectedStat = "PTS"
    @State private var showStatSelector = false
    @State private var dataReady = false
    
    @State private var isPressing = false
    @State private var pressing = 0
    @State private var timeFrameFilter = 5
    @State private var headerFilter = 0
    @State private var groupedHeaderFilter = 0
    @State private var splitBy = 0
    @State private var chartView = 0
    @State private var sortBy = "Game"
    @State private var sortBy0 = "Game"
    @State private var headerStats = ["PTS","FG_PCT","REB","AST"]
    @State private var statVstat = ["PTS", "REB"]
    @State private var pctChange = [Double]()
    
    let sortTypes = ["Game", "Vs Team", "Home/Away", "Pre/Post All-Star", "Month"]
    
    var pieChartData: [PieModel] {
        var pm : [PieModel] = []
        
        if !dataTotals.isEmpty {
            let dt = dataTotals[0]
            
            switch groupedHeaderFilter {
            case 1:
                pm.append(PieModel(title: "Offensive", val: Double(dt.oreb)/Double(dt.reb)))
                pm.append(PieModel(title: "Defensive", val: Double(dt.dreb)/Double(dt.reb)))
            case 2:
                pm.append(PieModel(title: "Blocks", val: Double(dt.blk)/Double(dt.age ?? 0)))
                pm.append(PieModel(title: "Steals", val: Double(dt.stl)/Double(dt.age ?? 0)))
            default:
                pm.append(PieModel(title: "Free Throws", val: Double(dt.ftm)/Double(dt.pts)))
                pm.append(PieModel(title: "2pt FG", val: Double(dt.gp)/Double(dt.pts)))
                pm.append(PieModel(title: "3pt FG", val: Double(dt.gs)/Double(dt.pts)))
            }
        }
        
        return pm
    }
    
    var body: some View {
        VStack {
            Picker("Data Period", selection: $timeFrameFilter) {
                Text("Last 5").tag(5)
                Text("Last 10").tag(10)
                Text("Last 15").tag(15)
                Text("Season").tag(0)
            }
            .pickerStyle(.segmented)
            .padding([.top, .horizontal])
            .onChange(of: timeFrameFilter, {
                withAnimation {
                    filterData()
                }
            })
            
            switch chartView {
            case 1:
                groupedHeader
            case 3:
                statVstatHeader
            default:
                traditionalHeader
            }
            
            Picker("Data Splits", selection: $splitBy) {
                Text("Traditional").tag(0)
                Text("Grouped").tag(1)
                Text("Trends").tag(2)
                Text("Stat v Stat").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: splitBy, {
                withAnimation {
                    if splitBy == 0 && sortBy0 != "" {
                        sortBy = sortBy0
                        sortBy0 = ""
                    }
                    
                    if splitBy == 3 {
                        sortBy0 = sortBy
                        sortBy = "Home/Away"
                    }
                    
                    filterData()
                    chartView = splitBy
                }
            })
            
            switch chartView {
            case 1:
                pieChart
            case 2:
                lineChart
            case 3:
                scatterPlot
            default:
                barGraph
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p.playerID).png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(uiImage: p.team.logo).resizable().aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 40, height: 30, alignment: .bottom)
                    
                    Text("\(p.firstName) \(p.lastName)").bold().padding(.leading, -10)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    withAnimation {
                        playerDataManager.showCharts = false
                    }
                }
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundStyle(Color(p.team.priColor))
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.8))
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: selectedStat, {
            withAnimation {
                updateStats()
                filterData()
            }
        })
        .onAppear(perform: {
            filterData()
        })
        .sheet(isPresented: $showStatSelector) {
            StatSelectView(selectedStat: $selectedStat, showStatSelector: $showStatSelector).presentationDetents([.fraction(0.4)])
        }
    }
    
    var traditionalHeader: some View {
        HStack {
            ForEach(headerStats.indices, id: \.self) { i in
                VStack(alignment: .leading) {
                    Text(getValueAsStr(criterion: headerStats[i]))
                        .font(.title2)
                        .foregroundStyle(headerFilter == i ? Color(p.team.priColor) : .primary)
                        .bold()
                    
//                    if headerStats[i].contains("PCT") {
//                        + Text(" %")
//                            .foregroundStyle(.secondary)
//                            .bold()
//                    }
                    
                    Text(getStatName(criterion:headerStats[i]))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation {
                        headerFilter = i
                        getCharts()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    var groupedHeader: some View {
        HStack {
            let stats = ["PTS", "REB", "DEF"]
            let statStr = ["Scoring", "Rebounding", "Defense"]
            
            ForEach(stats.indices, id: \.self) { i in
                VStack(alignment: .leading) {
                    Text(getValueAsStr(criterion: stats[i]))
                        .font(.title2)
                        .foregroundStyle(groupedHeaderFilter == i ? Color(p.team.priColor) : .primary)
                        .bold()
                    
                    Text(statStr[i])
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation {
                        groupedHeaderFilter = i
                    }
                }
                
                if i < stats.count - 1 {
                    Divider().frame(maxHeight: 44)
                }
            }
        }
        .padding(.horizontal)
    }
    
    var statVstatHeader: some View {
        HStack {
            ForEach(statVstat.indices, id: \.self) { i in
                VStack(alignment: .leading) {
                    Text(getValueAsStr(criterion: statVstat[i]))
                        .font(.title2)
                        .foregroundStyle(isPressing && pressing == i + 4 ? Color(p.team.priColor) : .primary)
                        .bold()
                    
                    Text(getStatName(criterion:statVstat[i]))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .scaleEffect(isPressing && pressing == i + 4 ? 1.2 : 1)
                .frame(maxWidth: .infinity)
                .onLongPressGesture {
                    withAnimation {
                        showStatSelector = true
                        selectedStat = statVstat[i]
                    }
                } onPressingChanged: { isPressing in
                    withAnimation {
                        self.pressing = i + 4
                        self.isPressing = isPressing
                    }
                }
                .sensoryFeedback(.selection, trigger: isPressing)
                
                if i < statVstat.count - 1 {
                    Divider().frame(maxHeight: 44)
                }
            }
        }
        .padding(.horizontal)
    }
    
    var barGraph: some View {
        VStack {
            ZStack(alignment: .top) {
                Chart {
                    ForEach(chartData, id: \.id) { game in
                        let team = Team.teamData.first(where: { $0.teamID == game.vsTeamID })
                        
                        BarMark(
                            x: .value("Y", game.val),
                            y: .value("X", game.sort)
                        )
                        .foregroundStyle(game.color)
                        .annotation(position: .trailing) {
                            Group {
                                HStack {
                                    if sortBy != "Home/Away" {
                                        Image(uiImage: team!.logo)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 20, height: 20)
                                    }
                                    
                                    Text(headerFilter != 1 ? String(Int(game.val)) : String(format: "%.1f", (Double(game.val) * 100)))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .clipShape(.rect(cornerRadius: 10))
                }
                .chartLegend(.hidden)
                .chartXAxis {
                    if headerStats[headerFilter].contains("PCT") {
                        AxisMarks(
                            format: Decimal.FormatStyle.Percent.percent.scale(100)
                        )
                    } else {
                        AxisMarks()
                    }
                }
                .chartYAxis {
                    if sortBy != "Vs Team" && sortBy != "Game" {
                        AxisMarks() { _ in
//                            AxisGridLine().foregroundStyle(.clear)
//                            AxisTick().foregroundStyle(.clear)
                            AxisValueLabel()
                        }
                    }
                }
                .padding(.horizontal)
                sortByView
            }
            
            sortTypeView
        }
    }
    
    var pieChart: some View {
        VStack {
            if !dataTotals.isEmpty {
                Chart(pieChartData) { pcd in
                    SectorMark(
                        angle: .value(
                            Text(verbatim: pcd.title),
                            pcd.val
                        ),
                        innerRadius: .ratio(0.7),
                        angularInset: 6
                    )
                    .foregroundStyle(
                        by: .value(
                            Text(verbatim: pcd.title),
                            pcd.title
                        )
                    )
                }
                .chartLegend(position: .overlay, alignment: .center)
                .padding(.horizontal, 40)
            } else {
                VStack {
                    Text("No data available")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack {
                let dt = dataTotals[0]
                
                switch groupedHeaderFilter {
                case 1:
                    VStack {
                        Text("\(dt.reb)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Rebounds")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: 100)
                    
                    Divider()
                        .frame(maxHeight: 60)
                    
                    VStack {
                        HStack {
                            Text("offensive")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 60)
                            
                            HStack {
                                Text("\(dt.oreb)")
                                    .fontWeight(.semibold)
                                
                                Text("| \(String(format: "%.1f", (pieChartData[0].val) * 100)) %")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("defensive")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 60)
                            
                            HStack {
                                Text("\(dt.dreb)")
                                    .fontWeight(.semibold)
                                
                                Text("| \(String(format: "%.1f", (pieChartData[1].val) * 100)) %")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                case 2:
                    VStack {
                        Text("\(dt.age ?? 0)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Stops")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: 100)
                    
                    Divider()
                        .frame(maxHeight: 60)
                    
                    VStack {
                        HStack {
                            Text("blocks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 40)
                            
                            HStack {
                                Text("\(dt.blk)")
                                    .fontWeight(.semibold)
                                
                                Text("| \(String(format: "%.1f", (pieChartData[0].val) * 100)) %")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("steals")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 40)
                            
                            HStack {
                                Text("\(dt.stl)")
                                    .fontWeight(.semibold)
                                
                                Text("| \(String(format: "%.1f", (pieChartData[1].val) * 100)) %")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                default:
                    VStack {
                        Text("\(dt.pts)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Points")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: 100)
                    
                    Divider()
                        .frame(maxHeight: 60)
                    
                    VStack {
                        HStack {
                            Text("from ft")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 40)
                            
                            HStack {
                                Text("\(dt.ftm)")
                                    .fontWeight(.semibold)
                                
                                Text("| \(String(format: "%.1f", (pieChartData[0].val) * 100)) %")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("from 2")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 40)
                            
                            HStack {
                                Text("\(dt.gp)")
                                    .fontWeight(.semibold)
                                
                                Text("| \(String(format: "%.1f", (pieChartData[1].val) * 100)) %")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("from 3")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 40)
                            
                            HStack {
                                Text("\(dt.gs)")
                                    .fontWeight(.semibold)
                                
                                Text("| \(String(format: "%.1f", (pieChartData[2].val) * 100)) %")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding([.vertical, .horizontal])
            .frame(maxWidth: .infinity, maxHeight: 100)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .shadow(radius: 10)
            .padding([.horizontal, .bottom])
        }
    }
    
    var lineChart: some View {
        VStack {
            ZStack(alignment: .bottom) {
                let linearGradient = LinearGradient(gradient: Gradient(colors: [Color(p.team.priColor).opacity(0.4), Color(p.team.priColor).opacity(0)]), startPoint: .top, endPoint: .bottom)
                
                if chartData.count > 4 {
                    Chart(chartData) {
                        LineMark(
                            x: .value("Stat", Int($0.sort) ?? 0),
                            y: .value("Value", $0.val)
                        )
                        .symbol(.circle)
                        .foregroundStyle(Color(p.team.priColor))
                        .interpolationMethod(.catmullRom)
                        
                        if let chartSelection {
                            RuleMark(x: .value("Stat", chartSelection))
                                .foregroundStyle(.gray.opacity(0.2))
                                .annotation( position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                                    RuleMarkContentView(val: chartData[chartSelection].val, criteria: headerStats[headerFilter], matchup: chartData[chartSelection].matchup, gameDate: chartData[chartSelection].gameDate)
                                }
                        }
                        
                        AreaMark(
                            x: .value("Stat", Int($0.sort) ?? 0),
                            y: .value("Value", $0.val)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(linearGradient)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartXSelection(value: $chartSelection)
                    .padding(.vertical)
                    
                    let totalChg = cvm.getTotalChange(chartData: chartData)
                    
                    HStack {
                        Image(systemName: cvm.getChangeImage(pc: totalChg))
                            .foregroundStyle(cvm.getChangeTint(pc: totalChg))
                        
                        Text("\(String(format: "%.1f", (totalChg))) % change")
                    }
                    .bold()
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(radius: 10)
                    .padding([.horizontal, .bottom])
                }
            }
            
            List {
                ForEach(chartData) { game in
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
                        
                        Text(headerStats[headerFilter].contains("PCT") ? "\(String(format: "%.1f", (game.val) * 100)) %" : "\(Int(game.val))")
                            .frame(maxWidth: .infinity)
                            .bold()
                        
                        HStack {
                            Image(systemName: cvm.getChangeImage(pc: game.pctChg ?? 0) )
                                .foregroundStyle(cvm.getChangeTint(pc: game.pctChg ?? 0))
                            
                            Text("\(String(format: "%.1f", (game.pctChg ?? 0))) %")
                        }
                        .frame(maxWidth: .infinity)
                        .bold()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .shadow(radius: 10)
        }
    }
    
    var scatterPlot: some View {
        VStack {
            ZStack(alignment: .top) {
                Chart(chartData) {
                    PointMark(
                        x: .value("Stat 1", $0.val),
                        y: .value("Stat 2", $0.val2 ?? 0)
                    )
                    .foregroundStyle(by: .value("Stat", $0.sort))
                }
                .chartLegend(position: .overlay, alignment: .topLeading)
                .chartXAxisLabel(position: .overlay, alignment: .bottom) {
                    Text("Points")
                        .opacity(0.5)
                }
                .chartYAxisLabel(position: .overlay, alignment: .trailing) {
                    Text("Rebounds")
                        .opacity(0.5)
                        .rotationEffect(.degrees(90))
                        .padding(.trailing, -20)
                }
                
                sortByView
            }
            
            sortTypeView
        }
    }
    
    var sortTypeView: some View {
        // Incorporate splits besides per game:
        // per team, home/away, time of year/game(early/late), pre/post all-star break, season type (career)
        ScrollView(.horizontal) {
            HStack {
                ForEach(sortTypes, id: \.self) { type in
                    Button(type) {
                        withAnimation {
                            sortBy = type
                            getCharts()
                        }
                    }
                    .disabled(getBtnDisabled(btn: type))
                    .foregroundStyle(.white)
                    .buttonStyle(.bordered)
                    .tint(sortBy == type ? Color(p.team.priColor) : .gray)
                    .opacity(sortBy == type ? 1 : 0.6)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .scrollIndicators(.hidden)
    }
    
    var sortByView: some View {
        HStack {
            Spacer()
            
            Text("Sorted by \(sortBy)")
                .italic()
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxHeight: 30)
        }
        .padding(.horizontal)
    }
    
    func filterData() {
        dataTotals.removeAll()
        filteredData = timeFrameFilter != 0 ? data.suffix(timeFrameFilter) : data
        getCharts()
        
        let min = filteredData.reduce(0, {$0 + Int(($1.min ?? 0))})
        let fgm = filteredData.reduce(0, {$0 + Int(($1.fgm ?? 0))})
        let fga = filteredData.reduce(0, {$0 + Int(($1.fga ?? 0))})
        let fg_pct = (Double(fgm)/Double(fga) * 100).formatted(.number.precision(.fractionLength(1)))
        let fg3m = filteredData.reduce(0, {$0 + Int(($1.fg3m ?? 0))})
        let fg3a = filteredData.reduce(0, {$0 + Int(($1.fg3a ?? 0))})
        let fg3_pct = (Double(fg3m)/Double(fg3a) * 100).formatted(.number.precision(.fractionLength(1)))
        let ftm = filteredData.reduce(0, {$0 + Int(($1.ftm ?? 0))})
        let fta = filteredData.reduce(0, {$0 + Int(($1.fta ?? 0))})
        let ft_pct = (Double(ftm)/Double(fta) * 100).formatted(.number.precision(.fractionLength(1)))
        let oreb = filteredData.reduce(0, {$0 + Int(($1.oreb ?? 0))})
        let dreb = filteredData.reduce(0, {$0 + Int(($1.dreb ?? 0))})
        let reb = filteredData.reduce(0, {$0 + Int(($1.reb ?? 0))})
        let ast = filteredData.reduce(0, {$0 + Int(($1.ast ?? 0))})
        let stl = filteredData.reduce(0, {$0 + Int(($1.stl ?? 0))})
        let blk = filteredData.reduce(0, {$0 + Int(($1.blk ?? 0))})
        let tov = filteredData.reduce(0, {$0 + Int(($1.tov ?? 0))})
        let pf = filteredData.reduce(0, {$0 + Int(($1.pf ?? 0))})
        let pts = filteredData.reduce(0, {$0 + Int(($1.min ?? 0))})
        let pts1 = ftm
        let pts3 = fg3m * 3
        let pts2 = pts - (pts1 + pts3)
        let def = stl + blk
        
        dataTotals.append(StatTotals(age: def, gp: pts2, gs: pts3, min: min, fgm: fgm, fga: fga, fg_pct: Double(fg_pct) ?? 0, fg3m: fg3m, fg3a: fg3a, fg3_pct: Double(fg3_pct) ?? 0, ftm: ftm, fta: fta, ft_pct: Double(ft_pct) ?? 0, oreb: oreb, dreb: dreb, reb: reb, ast: ast, stl: stl, blk: blk, tov: tov, pf: pf, pts: pts))
    }
    
    func getCharts() {
        var cd : [GameStat] = []
        
        let values = getChartY(criterion: headerStats[headerFilter])
        
        if splitBy == 3 {
            let spv1 = getChartY(criterion: statVstat[0])
            let spv2 = getChartY(criterion: statVstat[1])
            
            for i in filteredData.indices {
                cd.append(GameStat(gameID: filteredData[i].gameID, gameDate: filteredData[i].gameDate, matchup: filteredData[i].matchup, sort: filteredData[i].homeAway, val: spv1[i], val2: spv2[i], color: Color(filteredData[i].vsTeam.priColor)))
            }
        } else if splitBy == 2 {
            for i in filteredData.indices {
                var chg = 0.0
                
                if i > 0 {
                    chg = (values[i] - values[i - 1])/values[i - 1] * 100
                }
                
                cd.append(GameStat(gameID: filteredData[i].gameID, gameDate: filteredData[i].gameDate, matchup: filteredData[i].matchup, sort: "\(i)", val: values[i], pctChg: chg, color: Color(filteredData[i].vsTeam.priColor)))
            }
        } else {
            switch sortBy {
            case "Vs Team":
                var ft = [Int]()
                
                for game in filteredData {
                    if !ft.contains(game.vsTeamID) {
                        ft.append(game.vsTeamID)
                        
                        var v = 0.0
                        
                        for i in filteredData.indices {
                            if filteredData[i].vsTeamID == game.vsTeamID {
                                v += values[i]
                            }
                        }
                        
                        cd.append(GameStat(gameID: game.gameID, gameDate: game.gameDate, matchup: game.matchup, sort: "\(game.vsTeamID)", val: v, color: Color(game.vsTeam.priColor)))
                    }
                }
            case "Home/Away":
                var hv = 0.0
                var av = 0.0
                
                for i in filteredData.indices {
                    if filteredData[i].homeAway == "Home" {
                        hv += values[i]
                    } else {
                        av += values[i]
                    }
                }
                
                cd.append(GameStat(gameID: "1", gameDate: "", matchup: "", sort: "Home", val: hv, color: Color(p.team.priColor)))
                cd.append(GameStat(gameID: "2", gameDate: "", matchup: "", sort: "Away", val: av, color: .secondary))
            case "Pre/Post All-Star":
                break
            case "Month":
                break
            default:
                for i in filteredData.indices {
                    cd.append(GameStat(gameID: filteredData[i].gameID, gameDate: filteredData[i].gameDate, matchup: filteredData[i].matchup, sort: filteredData[i].gameID, val: values[i], color: Color(filteredData[i].vsTeam.priColor)))
                }
            }
        }
        
        chartData = cd
    }
    
    func getValueAsStr(criterion: String) -> String {
        var valueStr = "-1"
        
        if !dataTotals.isEmpty {
            let player = dataTotals[0]
            
            switch criterion {
            case "MIN":
                valueStr = String(player.min)
            case "FGM":
                valueStr = String(player.fgm)
            case "FGA":
                valueStr = String(player.fga)
            case "FG_PCT", "FG%":
                valueStr = String(player.fg_pct)
            case "FG3M":
                valueStr = String(player.fg3m)
            case "FG3A":
                valueStr = String(player.fg3a)
            case "FG3_PCT", "FG3%":
                valueStr = String(player.fg3_pct)
            case "FTM":
                valueStr = String(player.ftm)
            case "FTA":
                valueStr = String(player.fta)
            case "FT_PCT", "FT%":
                valueStr = String(player.ft_pct)
            case "OREB":
                valueStr = String(player.oreb)
            case "DREB":
                valueStr = String(player.dreb)
            case "REB":
                valueStr = String(player.reb)
            case "AST":
                valueStr = String(player.ast)
            case "STL":
                valueStr = String(player.stl)
            case "BLK":
                valueStr = String(player.blk)
            case "TOV":
                valueStr = String(player.tov)
            case "1PT":
                valueStr = String(player.ftm)
            case "2PT":
                valueStr = String(player.gp)
            case "3PT":
                valueStr = String(player.gs)
            case "DEF":
                valueStr = String(player.age ?? 0)
            default:
                valueStr = String(player.pts)
            }
        }
        
        return valueStr
    }
    
    func getChartY(criterion: String) -> [Double] {
        var y : [Double] = []
        
        // get y
        switch criterion {
        case "MIN":
            y = filteredData.map { $0.min ?? 0 }
        case "FGM":
            y = filteredData.map { $0.fgm ?? 0 }
        case "FGA":
            y = filteredData.map { $0.fga ?? 0 }
        case "FG_PCT":
            y = filteredData.map { $0.fg_pct ?? 0 }
        case "FG3M":
            y = filteredData.map { $0.fg3m ?? 0 }
        case "FG3A":
            y = filteredData.map { $0.fg3a ?? 0 }
        case "FG3_PCT":
            y = filteredData.map { $0.fg3_pct ?? 0 }
        case "FTM":
            y = filteredData.map { $0.ftm ?? 0 }
        case "FTA":
            y = filteredData.map { $0.fta ?? 0 }
        case "FT_PCT":
            y = filteredData.map { $0.ft_pct ?? 0 }
        case "OREB":
            y = filteredData.map { $0.oreb ?? 0 }
        case "DREB":
            y = filteredData.map { $0.dreb ?? 0 }
        case "REB":
            y = filteredData.map { $0.reb ?? 0 }
        case "AST":
            y = filteredData.map { $0.ast ?? 0 }
        case "STL":
            y = filteredData.map { $0.stl ?? 0 }
        case "BLK":
            y = filteredData.map { $0.blk ?? 0 }
        case "TOV":
            y = filteredData.map { $0.tov ?? 0 }
        default:
            y = filteredData.map { $0.pts ?? 0 }
        }
        
        return y
    }
    
    func getStatName(criterion: String) -> String {
        var statName = criterion
        
        switch criterion {
        case "MIN":
            statName = "Minutes"
        case "FGM":
            break
        case "FGA":
            break
        case "FG_PCT":
            statName = "FG%"
        case "FG3M":
            break
        case "FG3A":
            break
        case "FG3_PCT":
            statName = "FG3%"
        case "FTM":
            break
        case "FTA":
            break
        case "FT_PCT":
            statName = "FT%"
        case "OREB":
            break
        case "DREB":
            break
        case "REB":
            statName = "Rebounds"
        case "AST":
            statName = "Assists"
        case "STL":
            statName = "Steals"
        case "BLK":
            statName = "Blocks"
        case "TOV":
            statName = "Turnovers"
        case "PTS":
            statName = "Points"
        default:
            break
        }
        
        return statName
    }
    
    func updateStats() {
        if splitBy == 3 {
            statVstat[pressing == 4 ? 0 : 1] = selectedStat
        }
    }
    
    func getBtnDisabled(btn: String) -> Bool {
        var disabled = false
        var btns = sortTypes
        
        if splitBy == 3 {
            btns = [sortTypes[1], sortTypes[2]]
        }
        
        if !btns.contains(btn) {
            disabled = true
        }
        
        return disabled
    }
}

struct PieModel: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var val: Double
}

#Preview {
    ChartView(p: Player.demoPlayer, selectedStats: [StatTotals](), data: [GameStats]()).environmentObject(PlayerDataManager())
}
