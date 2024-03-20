//
//  CompareView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI
import Charts

struct CompareView: View {
    @StateObject var apiManager : DataManager
    
    @State private var showOverlay: Bool = true
    @State private var dataFilter = 0
    @State private var criteria = "PTS"
    
    @State var sp = Player.demoPlayer
    @State var p1 = Player.demoPlayer
    @State var p2 = Player.demoPlayer
    @State var pos = 0
    @State var p1Scale = 1.0
    @State var p2Scale = 1.0
    @State var b1Scale = 1.0
    @State var b2Scale = 1.0
    
    var p1ID : Int {
        return p1.playerID
    }
    
    var p2ID : Int {
        return p2.playerID
    }
    
    var spt : Team {
        if let team = Team.teamData.first(where: { $0.teamID == apiManager.sp?.teamID}) {
            return team
        } else {
            return Team.teamData.first(where: { $0.teamID == Player.demoPlayer.teamID}) ?? Team.teamData[30]
        }
    }
    
    var t1 : Team {
        if let team = Team.teamData.first(where: { $0.teamID == p1.teamID}) {
            return team
        } else {
            return Team.teamData[30]
        }
    }
    
    var t2 : Team {
        if let team = Team.teamData.first(where: { $0.teamID == p2.teamID}) {
            return team
        } else {
            return Team.teamData[30]
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Data Period", selection: $dataFilter) {
                    Text("Last 5").tag(0)
                    Text("Last 10").tag(1)
                    Text("Last 15").tag(2)
                    Text("Season").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                Divider()
                    .navigationTitle("Search and Compare")
                    .toolbarTitleDisplayMode(.inline)
                
//                var p1ID = 0
//                var p2ID = 0
//                
//                if !apiManager.searchResults.isEmpty {
//                    p1ID = apiManager.searchResults[0].playerID
//                    p2ID = apiManager.searchResults[1].playerID
//                }
                
                let totalStats = ["GP", "W", "L"]
                
                ZStack(alignment: .top) {
                    let data = getData()
                    
                    Chart(data, id: \.id) { dataSeries in
                        ForEach(dataSeries.statSeries) { d in
                            let i = dataSeries.statSeries.firstIndex(where: { $0.id == d.id })
                            LineMark(x: .value("Game", i! + 1), y: .value("PTS", d.value))
                        }
                        .foregroundStyle(by: .value("Player", dataSeries.id))
                        .symbol(by: .value("Game", dataSeries.id))
                    }
                    .chartXScale(domain: 1...getMaxX(data: data))
                    .chartLegend(.hidden)
//                    .chartXScale(type: .linear)
//                    .aspectRatio(1, contentMode: .fill)
//                    .frame(maxWidth: .infinity, alignment:. top)
//                    .background(.blue)
                    
                    
                    HStack {
                        Spacer()
                        
                        Picker("League Leaders", selection: $criteria) {
                            ForEach(getCriteria(), id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .background(.regularMaterial).clipShape(.capsule)
                        .onChange(of: criteria) {
                            apiManager.getChartData(criteria: criteria, pIDs: ["\(p1ID)", "\(p2ID)"])
                        }
                    }.padding(.horizontal, 20)
                }
                
                ZStack {
                    HStack {
                        if !apiManager.searchResults.isEmpty {
                            
                            VStack(alignment: .leading) {
                                AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p1ID).png")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(maxWidth: 250, maxHeight: 150)
                                .padding(.top, -100)
                                .padding(.leading, -50)
                                
                                HStack {
                                    Circle().fill(.blue).frame(width: 10, height: 10)
                                    Text("\(p1.firstName) \(p1.lastName)").font(.caption2)
                                }.padding(.bottom, -6).padding(.leading, 20)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p2ID).png")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(maxWidth: 250, maxHeight: 150)
                                .padding(.top, -100)
                                .padding(.trailing, -50)
                                
                                HStack {
                                    Text("\(p2.firstName) \(p2.lastName)").font(.caption2)
                                    Circle().fill(.green).frame(width: 10, height: 10)
                                }.padding(.bottom, -6).padding(.trailing, 20)
                            }
                        }
                    }
                    
//                    Text("Current Season Stats")
                }
                
                let gp = gamesPlayed()
                
                List {
                    ForEach(apiManager.statCompare, id: \.id) { stat in
                        ZStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(stat.value1)
                                        .font(.title2.bold())
                                    
                                    if !stat.stat.contains("PCT") && !totalStats.contains(stat.stat) {
                                        let pg = String(format: "%.1f", (Double(stat.value1) ?? 0) / gp[0])
                                        Text("\(pg) per game").font(.caption2)
                                    }
                                }
                                
                                Spacer ()
                                
                                VStack(alignment: .trailing) {
                                    Text(stat.value2)
                                        .font(.title2.bold())
                                    
                                    if !stat.stat.contains("PCT") && !totalStats.contains(stat.stat) {
                                        let pg = String(format: "%.1f", (Double(stat.value2) ?? 0) / gp[1])
                                        Text("\(pg) per game").font(.caption2)
                                    }
                                }
                            }
                            
                            Text(stat.stat)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    }.listStyle(.plain)
            }
        }
//        .blur(radius: showOverlay ? 9.0 : 0)
//            .opacity(showOverlay ? 0.3 : 1)
        .overlay(compareOverlay)
        .onAppear(perform: {
            if let sel = apiManager.sp {
                sp = sel
            }
            
            if let pl1 = apiManager.p1 {
                p1 = pl1
            } else {
                if !apiManager.searchResults.isEmpty {
                    p1 = apiManager.p1 ?? apiManager.searchResults[0]
                } else {
                    p1 = Player.demoPlayer
                }
            }
            
            if let pl2 = apiManager.p2 {
                p2 = pl2
            } else {
                if !apiManager.searchResults.isEmpty {
                    p2 = apiManager.p2 ?? apiManager.searchResults[1]
                } else {
                    p2 = Player.demoPlayer
                }
            }
        })
    }
    
    @ViewBuilder private var compareOverlay: some View {
        if showOverlay {
            VStack {
                Text("Set Matchup").font(.body).bold().padding(.vertical, 20)
                HStack {
                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(apiManager.sp?.playerID ?? Player.demoPlayer.playerID).png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(uiImage: spt.logo).resizable().aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 80, height: 60, alignment: .bottom)
                    
                    Text("\(apiManager.sp?.firstName ?? Player.demoPlayer.firstName) \(apiManager.sp?.lastName ?? Player.demoPlayer.lastName) selected").bold().italic()
                }.frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .shadow(color: Color(uiColor: spt.priColor), radius: 10)
                .padding(.bottom, 20)
                
                HStack {
                    ZStack {
                        VStack(alignment: .leading) {
                            Text(pos == 1 ? "\(apiManager.sp?.firstName ?? Player.demoPlayer.firstName)" : "\(p1.firstName)").font(.title).bold()
                            Text(pos == 1 ? "\(apiManager.sp?.lastName ?? Player.demoPlayer.lastName)" : "\(p1.lastName)").font(.system(size: 35)).fontWeight(.black).lineLimit(2).minimumScaleFactor(0.8).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.leading).padding(.top, -30)
                        }.scaleEffect(p1Scale)
                            .animation(.linear(duration: 0.1), value: p1Scale)
                            .frame(maxHeight: 160, alignment: .top)
                            .padding(.horizontal)
                        
                        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(pos == 1 ? (apiManager.sp?.playerID ?? Player.demoPlayer.playerID) : p1ID).png")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .shadow(color: pos == 1 ? Color(uiColor: spt.priColor) : .black, radius: 10)
                                .scaleEffect(p1Scale)
                                .animation(.linear(duration: 0.1), value: p1Scale)
                        } placeholder: {
                            Image(uiImage: t1.logo).resizable().aspectRatio(contentMode: .fill).opacity(pos == 1 ? 1 : 0.7)
                        }.frame(maxWidth: .infinity, maxHeight: 100)
                    }.opacity(pos == 1 ? 1 : 0.7)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            pos = 1
                            p1Scale = 1.3
                            p2Scale = 1.0
                        }
                    }
                    
                    Text("VS")
                    
                    ZStack {
                        VStack(alignment: .trailing) {
                            Text(pos == 2 ? "\(apiManager.sp?.firstName ?? Player.demoPlayer.firstName)" : "\(p2.firstName)").font(.title).bold()
                            Text(pos == 2 ? "\(apiManager.sp?.lastName ?? Player.demoPlayer.lastName)" : "\(p2.lastName)").font(.system(size: 35)).fontWeight(.black).lineLimit(2).minimumScaleFactor(0.8).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.trailing).padding(.top, -30)
                        }.scaleEffect(p2Scale)
                            .animation(.linear(duration: 0.1), value: p2Scale)
                            .frame(maxHeight: 160, alignment: .top)
                            .padding(.horizontal)
                        
                        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(pos == 2 ? (apiManager.sp?.playerID ?? Player.demoPlayer.playerID) : p2ID).png")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .shadow(color: pos == 2 ? Color(uiColor: spt.priColor) : .black, radius: 10)
                                .scaleEffect(p2Scale)
                                .animation(.linear(duration: 0.1), value: p2Scale)
                        } placeholder: {
                            Image(uiImage: t2.logo).resizable().aspectRatio(contentMode: .fill).opacity(pos == 2 ? 1 : 0.7)
                        }.frame(maxWidth: .infinity, maxHeight: 100)
                    }.opacity(pos == 2 ? 1 : 0.7)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            pos = 2
                            p2Scale = 1.3
                            p1Scale = 1.0
                        }
                    }
                }
                
                if pos != 0 {
                    Button {
                        if pos == 1 {
                            apiManager.p1 = sp
                            p1 = sp
                            p1Scale = 1.0
                            
                        } else {
                            apiManager.p2 = sp
                            p2 = sp
                            p2Scale = 1.0
                        }
                        
                        pos = 0
                        b1Scale = 1.0
                        b2Scale = 1.3
                        
                    } label: {
                        Text("Set Player \(pos)")
                    }.scaleEffect(b1Scale)
                        .animation(.easeOut(duration: 1).repeatForever(autoreverses: true), value: b1Scale)
                        .onAppear(perform: { self.b1Scale = 1.3 })
                    .buttonStyle(.bordered).tint(.orange)
//                        .padding()
                        .padding(.horizontal, 30)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: pos == 1 ? .leading : .trailing)
                }
                
                Button {
                    if !apiManager.searchResults.isEmpty {
                        Task {
                            await apiManager.compareStats(p1ID: "\(p1.playerID)", p2ID: "\(p2.playerID)", criteria: criteria)
                        }
                    }
                    
                    showOverlay.toggle()
                    apiManager.currentDetent = PresentationDetent.large
                } label: {
                    Text("Compare!")
                }.scaleEffect(pos == 0 ? 1.3 : 1.0)
                    .animation(.easeOut(duration: 1).repeatForever(autoreverses: true), value: 1.3)
                .buttonStyle(.borderedProminent).tint(.cyan)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.ultraThinMaterial)
            .onChange(of: apiManager.sp?.id) {
                pos = 0
                b1Scale = 1.0
                b2Scale = 1.0
                p2Scale = 1.0
                p1Scale = 1.0
                
                sp = apiManager.sp ?? Player.demoPlayer
            }
        }
    }
    
    func getCriteria() -> [String] {
        var c = [String]()
        let totalStats = ["GP", "W", "L"]
        
        for sc in apiManager.statCompare {
            if !sc.stat.contains("PCT") && !totalStats.contains(sc.stat) {
                c.append(sc.stat)
            }
        }
        
        return c
    }
    
    func gamesPlayed() -> [Double] {
        var gp = [Double]()

        if let g = apiManager.statCompare.first(where: { $0.stat == "GP"}) {
            gp.append(Double(g.value1) ?? 0)
            gp.append(Double(g.value2) ?? 0)
        }
        
        return gp
    }
    
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
        var d = apiManager.gameStatCompare
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
                fd.append(StatSeriesCompare(id: ds.id, statSeries: ds.statSeries.suffix(f)))
            }
            
            d = fd
        }
        
        return d
    }
}

#Preview {
    CompareView(apiManager: DataManager(), sp: Player.demoPlayer)
}
