//
//  PlayerDetailView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/12/24.
//

import SwiftUI
//import Foundation

struct PlayerDetailView: View {
    @StateObject var playerDataManager : PlayerDataManager
    @StateObject var favoritesManager : FavoritesManager
    
//    @State var isFav = false
    @State var seasons = [String]()
    @State private var season = "2023-24"
    @State private var selView = 0
    @State var seasonStats = SeasonStats()
    @State var gameStats : [GameStats] = []
    
    let p : Player
    
    var isFav : Bool {
        return favoritesManager.contains(p)
    }
//    @State private var downloadAmount = 0.0
    
    var body: some View {
        let team = p.team
        let pc = team.priColor
        
//        NavigationStack {
            VStack {
                ZStack {
                    Image(uiImage: team.logo).resizable().rotationEffect(.degrees(-35)).aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 250).overlay(Color(.systemBackground).opacity(0.8).frame(maxWidth: .infinity, maxHeight: 250))
                        .clipped().padding(.trailing, -200).ignoresSafeArea()
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Button {
//                                isFav.toggle()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if isFav {
                                        favoritesManager.remove(p)
                                    } else {
                                        favoritesManager.add(p)
                                    }
                                }
                            } label: {
                                Image(systemName: isFav ? "star.fill" : "star")
                                Text(isFav ? "Favorited" : "Favorite")
                            }.padding(7).fontWeight(.bold).font(.caption)
                                .foregroundStyle(isFav ? AnyShapeStyle(.background) : AnyShapeStyle(.secondary))
                                .background(
                                    RoundedRectangle(
                                          cornerRadius: 20,
                                          style: .circular
                                      )
                                      .stroke(isFav ? Color.primary : Color.secondary, lineWidth: 3)
                                      .fill(isFav ? AnyShapeStyle(Color(pc)) : AnyShapeStyle(.regularMaterial))
                                ).padding(.vertical, 20)
                            
                            Spacer()
                            
                            Text(p.firstName).padding(.bottom, -20)
                            Text(p.lastName).font(.largeTitle).fontWeight(.black).frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(p.position ?? "-").bold()
                                Divider().frame(maxWidth: 2).overlay(.background).padding(.vertical, -10)
                                Text("#\(p.jersey ?? "-")").bold()
                            }.foregroundStyle(.background).padding(.horizontal, 8).padding(.vertical, 2).background(
                                RoundedRectangle(
                                    cornerRadius: 4,
                                    style: .continuous
                                )
                                .fill(Color(pc))).padding(.top, -20).padding(.bottom, 20)
                        }.frame(maxHeight: 150)
                        
                        Spacer()
                    }.padding(.horizontal, 20)
                    
                    AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(p.playerID).png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(maxWidth: 155, maxHeight: 155, alignment: .trailing)
                    }.frame(maxWidth: .infinity, maxHeight: 155, alignment: .trailing)
                }.frame(maxHeight: 150)
                
                // Per game stats.
                HStack(spacing: 0) {
                    VStack {
                        let s = String(format: "%.1f", (Double((seasonStats.pts
                                                               ?? -1)/(seasonStats.gp
                                                                       ?? -1))))
                        Text("\(s)").bold()
                        Text("PPG").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                    
//                    Divider()
                    
                    VStack {
                        let s = String(format: "%.1f", (Double((seasonStats.reb
                                                               ?? -1)/(seasonStats.gp
                                                                       ?? -1))))
                        Text("\(s)").bold()
                        Text("RPG").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                    
//                    Divider()
                    
                    VStack {
                        let s = String(format: "%.1f", (Double((seasonStats.ast
                                                               ?? -1)/(seasonStats.gp
                                                                       ?? -1))))
                        Text("\(s)").bold()
                        Text("APG").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                    
//                    Divider()
                    
                    VStack {
                        Text("\(Int(seasonStats.gp ?? 0))").bold()
                        Text("GP").font(.caption2)
                    }.frame(maxWidth:  .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                }.background(Color(pc)).frame(maxHeight: 30).padding(.top,8)
                
                // Player info section
                HStack(spacing: 0) {
                    VStack {
                        Text("\(p.attr)").font(.caption).bold()
                    }.frame(maxWidth: .infinity).foregroundStyle(Color(pc))
                    
                    Divider().frame(maxWidth: 1).overlay(Color(pc)).padding(.vertical, -8)
                    
                    VStack {
                        Text("\(p.draft)").font(.caption).bold().foregroundStyle(Color(pc))
                        Text("Draft").font(.caption2).foregroundStyle(.tertiary)
                    }.frame(maxWidth: .infinity)
                }.frame(maxHeight: 15).padding(.top).padding(.bottom, 4)
                
                Divider().frame(maxHeight: 1).overlay(Color(pc)).padding(.horizontal, 4)
                
                HStack(spacing: 0) {
                    VStack {
                        Text("\(p.birthDate ?? "-")").font(.caption).bold().foregroundStyle(Color(pc))
                        Text("Birthday").font(.caption2).foregroundStyle(.tertiary)
                    }.frame(maxWidth: .infinity)
                    
                    Divider().frame(maxWidth: 1).overlay(Color(pc)).padding(.vertical, -8)
                    
                    VStack {
                        Text("\(p.country ?? "-1")").font(.caption).bold().foregroundStyle(Color(pc))
                        Text("Country").font(.caption2).foregroundStyle(.tertiary)
                    }.frame(maxWidth: .infinity)
                }.frame(maxHeight: 15).padding(.vertical, 4)
                
                Divider().frame(maxHeight: 1).overlay(Color(pc)).padding(.horizontal, 4)
                
                HStack(spacing: 0) {
                    VStack {
                        Text("\(p.college ?? "-")").font(.caption).bold().foregroundStyle(Color(pc))
                        Text("School").font(.caption2).foregroundStyle(.tertiary)
                    }.frame(maxWidth: .infinity)
                    
                    Divider().frame(maxWidth: 1).overlay(Color(pc)).padding(.vertical, -8)
                    
                    VStack {
                        Text("\(p.exp ?? "-1")").font(.caption).bold().foregroundStyle(Color(pc))
                        Text("Experience").font(.caption2).foregroundStyle(.tertiary)
                    }.frame(maxWidth: .infinity)
                }.frame(maxHeight: 15).padding(.vertical, 4)

                Divider().frame(maxHeight: 2).overlay(Color(pc))
                
//                Picker("Season", selection: $season) {
//                    ForEach(apiManager.seasons, id: \.self) {
//                        Text($0)
//                    }
//                }
//                .pickerStyle(.menu)
//                .background(.regularMaterial).clipShape(.capsule)
//                .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 20)
//                .onChange(of: season) {
////                    apiManager.getChartData(criteria: criteria, pIDs: ["\(p1ID)", "\(p2ID)"])
//                }
                
                Picker("View", selection: $selView) {
                    Text("Stats").tag(0)
                    Text("Roster").tag(1)
                    Text("News").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.top, 5)
                .padding(.horizontal, 20)
                
                if selView == 0 {
                    if !gameStats.isEmpty {
                        Table(gameStats) {
                            TableColumn("VS", value: \.matchup)
                            TableColumn("Date", value: \.gameDate)
                            TableColumn("W/L", value: \.wl)
                            TableColumn("MIN") { stat in Text(String(format: "%.1f", stat.min ?? -1)) }
                            TableColumn("PTS") { stat in Text(String(format: "%.1f", stat.pts ?? -1)) }
                            TableColumn("FGM") { stat in Text(String(format: "%.1f", stat.fgm ?? -1)) }
                            TableColumn("FGA") { stat in Text(String(format: "%.1f", stat.fga ?? -1)) }
                            TableColumn("FG%") { stat in Text(String(format: "%.1f", stat.fg_pct ?? -1)) }
                            TableColumn("3PM") { stat in Text(String(format: "%.1f", stat.fg3m ?? -1)) }
                            TableColumn("3PA") { stat in Text(String(format: "%.1f", stat.fg3a ?? -1)) }
//                            TableColumn("3P%") { stat in Text(String(format: "%.1f", stat.fg3_pct ?? -1)) }
//                            TableColumn("FTM") { stat in Text(String(format: "%.1f", stat.ftm ?? -1)) }
//                            TableColumn("FTA") { stat in Text(String(format: "%.1f", stat.fta ?? -1)) }
//                            TableColumn("FT%") { stat in Text(String(format: "%.1f", stat.ft_pct ?? -1)) }
//                            TableColumn("OREB") { stat in Text(String(format: "%.1f", stat.oreb ?? -1)) }
//                            TableColumn("DREB") { stat in Text(String(format: "%.1f", stat.dreb ?? -1)) }
//                            TableColumn("REB") { stat in Text(String(format: "%.1f", stat.reb ?? -1)) }
//                            TableColumn("AST") { stat in Text(String(format: "%.1f", stat.ast ?? -1)) }
//                            TableColumn("STL") { stat in Text(String(format: "%.1f", stat.stl ?? -1)) }
//                            TableColumn("BLK") { stat in Text(String(format: "%.1f", stat.blk ?? -1)) }
//                            TableColumn("TOV") { stat in Text(String(format: "%.1f", stat.tov ?? -1)) }
//                            TableColumn("PF") { stat in Text(String(format: "%.1f", stat.pf ?? -1)) }
//                            TableColumn("+/-") { stat in Text(String(format: "%.1f", stat.pm ?? -1)) }
                        }
                    }
                } else if selView == 1 {
                    
                } else {
                    Text(p.lastName)
                }
                
                Spacer()
                
//                Text(p.lastName)
//                ProgressView("Downloading…", value: downloadAmount, total: 100)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(team.homeTown).bold().padding(.trailing, -10)
                        Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 50, alignment: .center)
                        Text(team.teamName).bold().padding(.leading, -10)
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
//        }
        .onAppear(perform: {   Task{
            await getPlayerStats()
//            _ = await playerDataManager.getPlayerStats(pID: p.playerID)
//            r = await apiManager.getTeamRoster(teamID: "\(team.teamID)")
//            TestFile().download(pID: p.playerID) { progress in
//                downloadAmount = Double(progress)
//            }
        } })
        
//        Text("\(p.firstName)")
//        Text("\(p.lastName)")
//        Text("\(p.jersey  ?? "-1")")
//        Text("\(p.position  ?? "UNK")")
//        Text("\(p.height ?? "0-0")")
//        Text("\(p.weight ?? "-")")
//        Text("\(p.birthDate  ?? "-")")
//        Text("\(p.age  ?? -1)")
//        
//        Text("\(p.exp ?? "-")")
//        Text("\(p.college ?? "-")")
//        Text("\(p.country  ?? "-")")
//        Text("\(p.draftYear  ?? "-")")
//        Text("\(p.draftRound ?? "-")")
//        Text("\(p.rosterStatus ?? "-")")
//        Text("\(p.howAcquired  ?? "-")")
    }
    
    func getPlayerStats() async {
        _ = await playerDataManager.getPlayerStats(pID: p.playerID)
        _ = await playerDataManager.getPlayerGameStats(pID: p.playerID)
//        _ = await playerDataManager.testFunc(pID: p.playerID)
        if let stats = playerDataManager.playerStats.first(where: { $0.playerID == p.playerID }) {
            for k in stats.seasonStats.keys {
//                print(k)
                seasons.append(k)
            }
            
            if let ss = stats.seasonStats["2023-24"] {
                seasonStats =  ss
            }
        }
        
        if let gs = playerDataManager.playerGameStats.first(where: { $0.playerID == p.playerID && $0.season == season })?.gameStats {
            gameStats = gs
        }
    }
}

#Preview {
    PlayerDetailView(playerDataManager: PlayerDataManager(), favoritesManager: FavoritesManager(), p: Player.demoPlayer)
}
