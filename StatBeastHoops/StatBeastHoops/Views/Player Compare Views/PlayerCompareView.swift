//
//  PlayerCompareView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/9/24.
//

import SwiftUI
import Charts

struct PlayerCompareView: View {
    @StateObject var vm : PlayerCompareViewModel
    @StateObject var cvm = CompareViewModel()
    @StateObject var playerDataManager : PlayerDataManager

    @State private var statSetType = 0
//    @State private var statSet = [StatCompare]()
    @State private var dataFilter = 0
    @State private var criteria = "PTS"
    
//    @State var p1 = Player.demoPlayer
//    @State var p2 = Player.demoPlayer
//    @State var data = [StatSeriesCompare]()
    
    var data : [StatSeriesCompare] {
        var d = cvm.gameStatCompare
        var f = 0
        
        switch dataFilter {
        case 0:
            f = 5
        case 1:
            f = 10
        case 2:
            f = 15
        default:
            break
        }
        
        if !(f == 0) {
            var fd = [StatSeriesCompare]()

            for ds in d {
                fd.append(StatSeriesCompare(id: ds.id, statSeries: ds.statSeries.suffix(f), color: ds.color))
            }
            
            d = fd
        }

        return d
    }
    
    var p1ID : Int {
        return cvm.p1!.playerID
    }
    
    var p2ID : Int {
        return cvm.p2!.playerID
    }
    
    var t1 : Team {
        if let team = Team.teamData.first(where: { $0.teamID == cvm.p1?.teamID }) {
            return team
        } else {
            return Team.teamData[30]
        }
    }
    
    var t2 : Team {
        if let team = Team.teamData.first(where: { $0.teamID == cvm.p2?.teamID }) {
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
    
    var compareReady : Bool {
        return cvm.compareReady
    }
    
    var statSet : [StatCompare] {
        return statSetType == 0 ? cvm.oppOnCourt : cvm.statCompare
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Matchup card
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
//                        .clipShape(.rect(cornerRadius: 16))
                        
                        Text("VS").font(.system(size: 60)).fontWeight(.black).foregroundStyle(.ultraThinMaterial).frame(maxHeight: 100)
//                            .padding(.top, 20)
                        
                        VStack {
//                            HStack {
//                                Text("MATCHUP").foregroundStyle(.tertiary).bold()
//                                
//                                Spacer()
//                                
//                                Button {
////                                    vm.showSetup = true
//                                } label: {
//                                    Text("Save Matchup")
////                                    Image(systemName: "square.and.arrow.down").foregroundStyle(.tertiary)
//                                }
//                                .buttonStyle(.bordered)
//                            }
//                            .padding(.horizontal)
//                            .frame(maxWidth: .infinity, maxHeight: 40)
//                            .background(.ultraThinMaterial)
                            
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
//                            .clipShape(.rect(cornerRadius: 16))
                        }
                    }
                    
                    // Player names
                    HStack {
                        HStack {
                            Circle().fill(Color(t1.priColor)).frame(width: 10, height: 10)
                            Text("\(cvm.p1!.firstName) \(cvm.p1!.lastName)").font(.caption).bold()
                            Text(cvm.p1!.team.abbr).font(.caption).foregroundStyle(.tertiary)
                        }.padding(.leading)
                        
                        Spacer()
                        
                        HStack {
                            Text(cvm.p2!.team.abbr).font(.caption).foregroundStyle(.tertiary)
                            Text("\(cvm.p2!.firstName) \(cvm.p2!.lastName)").font(.caption).bold()
                            Rectangle().fill(Color(t2.priColor)).frame(width: 10, height: 10)
                        }.padding(.trailing)
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                }
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.vertical)
                
                // Comparison card
                let totalStats = ["GP", "W", "L"]
//                let gp = gamesPlayed
                
                ScrollView {
                    VStack {
                        Picker("Stat Set", selection: $statSetType) {
                            Text("Head-to-Head").tag(0)
                            Text("Overall").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding([.top, .horizontal])
                        
                        Text("2023-24 Regular Season Stats").font(.caption).foregroundStyle(.tertiary)
                        
                        if !compareReady {
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
                            .frame(height: 200)
                        }
                        
//                        if statSetType == 0 {
                            HStack {
                                Text(statSetType == 0 ? "opponent on court" : "").font(.caption).bold()
                                Text(statSetType == 0 ? "opponent off court" : "").font(.caption2).foregroundStyle(.secondary)
                            }
                            .padding(.bottom, 6)
                            .padding(.top, 2)
//                        } else {
//                            Text("")
//                                .padding(.bottom, 6)
//                                .padding(.top, 2)
//                        }
                    }
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                    
                    // Chart
                    VStack {
                        Picker("Data Period", selection: $dataFilter) {
                            Text("Last 5").tag(0)
                            Text("Last 10").tag(1)
                            Text("Last 15").tag(2)
                            Text("Season").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        if !compareReady {
                            ProgressView().padding().controlSize(.large)
                        } else {
                            ZStack(alignment: .top) {
                                Chart(data, id: \.id) { dataSeries in
                                    ForEach(dataSeries.statSeries) { d in
                                        let i = dataSeries.statSeries.firstIndex(where: { $0.id == d.id })
                                        
                                        LineMark(x: .value("Game", i! + 1), y: .value("Stat", d.value))
                                            .foregroundStyle(dataSeries.color)
//                                            .interpolationMethod(.catmullRom)
                                    }
                                    .symbol(by: .value("Player", dataSeries.id))
                                }
                                .chartXScale(domain: 1...getMaxX(data: data))
                                .chartLegend(.hidden)
                                .frame(height: 400)
                                .padding()
//                                .chartXScale(type: .linear)
//                                .aspectRatio(1, contentMode: .fill)
//                                .frame(maxWidth: .infinity, alignment:. top)
//                                .background(.blue)
                                
                                HStack {
                                    Spacer()
                                    
                                    Picker("Criteria", selection: $criteria) {
                                        ForEach(getCriteria(), id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .background(.regularMaterial).clipShape(.capsule)
                                    .onChange(of: criteria) {
                                        cvm.getChartData(criteria: criteria, pIDs: ["\(p1ID)", "\(p2ID)"])
                                    }
                                }.padding(.horizontal, 20)
                            }
                        }
                    }
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.vertical)
                    
                    // Advantage card
//                    if !compareReady {
//                        ProgressView().padding().controlSize(.large)
//                    } else {
                        winnersCard
//                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Compare Players").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            print("Save Matchup")
                        } label: {
//                            Text("Save Matchup")
                            Image(systemName: "star")
                        }
                        
                        Button {
                            vm.showSetup = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $vm.showSetup) {
            CompareSetupView(vm: vm, cvm: cvm, playerDataManager: playerDataManager)
        }
        .onAppear(perform: {
            // Comment this entire onAppear section to prevent preview from crashing while developing.
            if cvm.p1!.playerID == cvm.p2!.playerID {
                cvm.p1 = playerDataManager.leaders[0]
                cvm.p2 = playerDataManager.leaders[1]
            }
            
            Task {
                await cvm.compareStats(p1ID: "\(cvm.p1!.playerID)", p2ID: "\(cvm.p2!.playerID)", criteria: criteria)
//                statSet = cvm.oppOnCourt
            }
        })
    }
    
    var winnersCard: some View {
        ZStack {
            if !compareReady {
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
                //            .clipShape(.rect(cornerRadius: 16))
                
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
                        
                        let pn = w == 1 ? "\(cvm.p1!.firstName) \(cvm.p1!.lastName)" : "\(cvm.p2!.firstName) \(cvm.p2!.lastName)"
                        
                        Text("Advantage \(pn)").foregroundStyle(.ultraThickMaterial).bold().padding(.leading, -20).padding(.trailing)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    //                .clipShape(.rect(cornerRadius: 16))
                }
            }
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.bottom)
    }
//    var headshotView: some View {
//        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { phase in
//            switch phase {
//            case .empty:
//                Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//            case .success(let image):
//                let _ = DispatchQueue.main.async {
//                    playerDataManager.playerHeadshots.append(PlayerHeadshot(playerID: player.playerID, pic: image))
//                }
//                
//                image.resizable().scaledToFit()
//            case .failure:
//                Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//            @unknown default:
//                Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
//            }
//        }
//        .frame(width: 80, height: 60, alignment: .bottom)
//        .padding(.trailing, -20)
//    }
    
    func getCriteria() -> [String] {
        var c = [String]()
        let totalStats = ["GP", "W", "L"]
        
        for sc in cvm.statCompare {
            if !sc.stat.contains("PCT") && !totalStats.contains(sc.stat) {
                c.append(sc.stat)
            }
        }
        
        return c
    }
    
//    func gamesPlayed() -> [Double] {
//        var gp = [Double]()
//        print(cvm.statCompare.isEmpty)
//        if let g = cvm.statCompare.first(where: { $0.stat == "GP" }) {
//            gp.append(Double(g.value1) ?? 0)
//            gp.append(Double(g.value2) ?? 0)
//        } else {
//            print("couldn't find stat")
//        }
//        print(gp)
//        return gp
//    }
    
    func getMaxX(data: [StatSeriesCompare]) -> Int {
        var maxX = 1
        
        for ds in data {
            if ds.statSeries.count > maxX {
                maxX = ds.statSeries.count
            }
        }
        
        return maxX
    }
    
    func getData() -> [StatSeriesCompare] {
        var d = cvm.gameStatCompare
        var f = 0
        
        switch dataFilter {
        case 0:
            f = 5
        case 1:
            f = 10
        case 2:
            f = 15
        default:
            break
        }
        
        if !(f == 0) {
            var fd = [StatSeriesCompare]()

            for ds in d {
//                print(ds.statSeries.suffix(f))
                fd.append(StatSeriesCompare(id: ds.id, statSeries: ds.statSeries.suffix(f), color: ds.color))
            }
            
            d = fd
        }

        return d
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
//        return pts1 > pts2 ? "\(cvm.p1!.firstName) \(cvm.p1!.lastName)" : "\(cvm.p2!.firstName) \(cvm.p2!.lastName)"
        return pts1 > pts2 ? 1 : 2
    }
    
//    func getLineColor(id: Int) -> UIColor {
//        print(id)
//        return id == p1.playerID ? t1.priColor : t2.priColor
//    }
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

#Preview {
    PlayerCompareView(vm: PlayerCompareViewModel(), playerDataManager: PlayerDataManager())
}
