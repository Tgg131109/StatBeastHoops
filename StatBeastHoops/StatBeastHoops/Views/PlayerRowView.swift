//
//  PlayerRowView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/15/24.
//

import SwiftUI

struct PlayerRowView: View {
    @StateObject var apiManager : DataManager
    
//    @State private var showComparePage: Bool = false
//    @State private var showCompareOptions: Bool = false
    @State private var selectedPlayer : Player?
//    @State private var currentDetent = PresentationDetent.height(400)
    
    var player : Player
    var rowType : String
    
//    var p1 : Player? = nil
//    var p2 : Player? = nil
    
    var body: some View {
//        let team = getTeam()
        
        let rn = (rowType == "leaders" ? "\(player.rank ?? 0)" : player.jersey) ?? "-"
        let pc = player.team.priColor
        
        ZStack(alignment: .center) {
            NavigationLink {
                PlayerDetailView(apiManager: apiManager, p: player)
            } label: {
                ZStack(alignment: .center) {
                    Text(rn).font(.system(size: 60)).fontWeight(.black).foregroundStyle(.tertiary).frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        VStack {
                            Spacer()
                            AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
                            }
                            .frame(width: 80, height: 60, alignment: .bottom)
                            .padding(.trailing, -20)
                            //                        .padding(.bottom, -25)
                        }
                        
                        let pos = player.position ?? "-"
                        let ht = player.height ?? "-"
                        let wt = player.weight ?? "-"
                        let bd = player.birthDate ?? "-"
                        let age = player.age ?? nil
                        let exp = player.exp ?? "-"
                        let sch = player.college ?? "-"
                        let ha = player.howAcquired ?? "-"
                        
                        VStack(alignment: .leading) {
                            
                            Text(player.firstName).padding(.bottom, -10)
                            Text(player.lastName).font(.title2).minimumScaleFactor(0.1).bold()
                            HStack {
                                HStack(alignment: .bottom) {
                                    Text(pos)
                                    Divider().frame(maxWidth: 2).overlay(.background).padding(.vertical, -10)
                                    Text("#\(player.jersey ?? "-")")
                                }.font(.caption).bold().foregroundStyle(.background).padding(.horizontal, 8).padding(.vertical, 2).background(
                                    RoundedRectangle(
                                        cornerRadius: 4,
                                        style: .continuous
                                    )
                                    .fill(Color(pc))
                                )
                                
                                Button {
                                    apiManager.sp = player
                                    
                                    if !apiManager.showComparePage {
                                        print("show")
                                        apiManager.showComparePage.toggle()
                                    } else {
                                        print(apiManager.sp?.id)
                                    }
                                } label: {
//                                    Image(systemName: "figure.basketball")
//                                    Image(systemName: "figure.basketball")
//                                    Image(systemName: "figure.stand.line.dotted.figure.stand")
                                    Image(systemName: "person.line.dotted.person.fill")
//                                    Image(systemName: "person.line.dotted.person")
                                }.foregroundStyle(Color(uiColor: pc))
                            }.frame(maxHeight: 10).padding(.top, -10)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            if rowType == "leaders" {
                                if let s = player.pts {
                                    Text(String(format: "%.1f", s)).font(.title2).fontWeight(.bold)
                                }
                                Text("PPG").font(.caption2)
                            } else {
                                HStack {
                                    VStack {
                                        Text("\(ht)").font(.caption).bold()
                                        Text("Ht").font(.caption2).foregroundStyle(.tertiary)
                                    }
                                    
                                    VStack {
                                        Text("\(wt)").font(.caption).bold()
                                        Text("Wt").font(.caption2).foregroundStyle(.tertiary)
                                    }
                                    
                                    VStack {
                                        Text("\(age ?? 0)").font(.caption).bold()
                                        Text("Age").font(.caption2).foregroundStyle(.tertiary)
                                    }
                                }
                                
                                Text("\(ha)").font(.caption2).padding(.top, 2)
                                Text("\(sch)").font(.caption2).bold()
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
//        .sheet(isPresented: $showComparePage) {
//            CompareView(apiManager: apiManager, sp: player).presentationDetents([.medium, .large, .fraction(0.8), .height(400)],selection: $apiManager.currentDetent)
//                .presentationBackgroundInteraction(.enabled)
//        }
    }
    
//    func getTeam() -> Team {
//        var team : Team
//        
//        if let t = Team.teamData.first(where: { $0.teamID == player.teamID }) {
//            team = t
//        } else {
//            team = Team.teamData[30]
//        }
//        
//        return team
//    }
}

#Preview {
    PlayerRowView(apiManager: DataManager(), player: Player.demoPlayer, rowType: "players")
}
