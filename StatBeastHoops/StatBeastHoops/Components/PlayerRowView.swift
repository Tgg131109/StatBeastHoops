//
//  PlayerRowView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/15/24.
//

import SwiftUI

struct PlayerRowView: View {
    @EnvironmentObject var playerDataManager : PlayerDataManager
    
    @State private var selectedPlayer : Player?
    
    var player : Player
    var rowType : String
    var criterion: String = "PTS"
    
    var body: some View {
        let rn = (rowType == "leaders" ? "\(player.rank ?? 0)" : player.jersey) ?? "-"
        let pc = player.team.priColor
        
        NavigationLink {
            PlayerDetailView(p: player.team.roster?.first(where: { $0.playerID == player.playerID }) ?? player)
        } label: {
            ZStack(alignment: .center) {
                if rowType != "players" {
                    Text(rn)
                        .font(.system(size: 60))
                        .fontWeight(.black)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Image(uiImage: player.team.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                }
                
                HStack {
                    VStack {
                        Spacer()
                        
                        headshotView
                    }
                    
                    let pos = player.position ?? "-"
                    let ht = player.height ?? "-"
                    let wt = player.weight ?? "-"
                    let bd = player.birthDate ?? "-"
                    let age = player.age ?? nil
                    let exp = player.experience ?? "-"
                    let sch = player.college ?? "-"
                    let ha = player.howAcquired ?? "-"
                    
                    VStack(alignment: .leading) {
                        Text(player.firstName)
                            .padding(.bottom, -10)
                        
                        Text(player.lastName)
                            .font(.title2)
                            .minimumScaleFactor(0.1)
                            .bold()
                        
                        HStack {
                            if rowType == "leaders" {
                                Image(uiImage: player.team.logo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 25)
                                
                                Text(player.team.abbr)
                                    .foregroundStyle(.tertiary)
                                    .bold()
                                    .font(.callout)
                            } else {
                                HStack(alignment: .bottom, spacing: 2) {
                                    Text(pos)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color(pc))
                                        .cornerRadius(4, corners: [.bottomLeft, .topLeft])
                                    
                                    Text("#\(player.jersey ?? "-")")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color(pc))
                                        .cornerRadius(4, corners: [.bottomRight, .topRight])
                                }
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.background)
                            }
                        }.frame(maxHeight: 10).padding(.top, -10)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if rowType == "leaders" {
                            let isTotal = playerDataManager.leaderTotalCats.contains(criterion.replacingOccurrences(of: "%", with: "_PCT"))
                            
                            Text(getStatStr(isTotal: isTotal))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(criterion.replacingOccurrences(of: "_PCT", with: "%"))")
                                .font(.caption2)
                            
                            Text(isTotal ? "season total" : "per game")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        } else if rowType == "roster" {
                            HStack {
                                VStack {
                                    Text("\(ht)")
                                        .font(.caption)
                                        .bold()
                                    
                                    Text("Ht")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                VStack {
                                    Text("\(wt)")
                                        .font(.caption)
                                        .bold()
                                    
                                    Text("Wt")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                VStack {
                                    Text("\(age ?? 0)")
                                        .font(.caption)
                                        .bold()
                                    
                                    Text("Age")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            
                            Text("\(ha)")
                                .font(.caption2)
                                .padding(.top, 2)
                            
                            Text("\(sch)")
                                .font(.caption2)
                                .bold()
                        } else {
                            HStack {
                                VStack {
                                    Text("\(String(format: "%.1f", player.pts ?? -1))")
                                        .font(.title3)
                                        .bold()
                                    
                                    Text("PTS")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                VStack {
                                    Text("\(String(format: "%.1f", player.reb ?? -1))")
                                        .font(.title3)
                                        .bold()
                                    
                                    Text("REB")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                VStack {
                                    Text("\(String(format: "%.1f", player.ast ?? -1))")
                                        .font(.title3)
                                        .bold()
                                    
                                    Text("AST")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var headshotView: some View {
        AsyncImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/1040x760/\(player.playerID).png")) { phase in
            switch phase {
            case .empty:
                Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
            case .success(let image):
//                let _ = DispatchQueue.main.async {
//                    playerDataManager.playerHeadshots.append(PlayerHeadshot(playerID: player.playerID, pic: image))
//                }
                
                image.resizable().scaledToFit()
            case .failure:
                Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
            @unknown default:
                Image(uiImage: player.team.logo).resizable().aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 80, height: 60, alignment: .bottom)
        .padding(.trailing, -20)
    }
    
    func getStatStr(isTotal: Bool) -> String {
        var valueStr = "-1"
        
        switch criterion {
        case "GP":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.gp ?? -1)
        case "MIN":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.min ?? -1)
        case "FGM":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.fgm ?? -1)
        case "FGA":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.fga ?? -1)
        case "FG_PCT", "FG%":
            valueStr = String(format: "%.1f", (player.fg_pct ?? -1) * 100)
        case "FG3M":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.fg3m ?? -1)
        case "FG3A":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.fg3a ?? -1)
        case "FG3_PCT", "FG3%":
            valueStr = String(format: "%.1f", (player.fg3_pct ?? -1) * 100)
        case "FTM":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.ftm ?? -1)
        case "FTA":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.fta ?? -1)
        case "FT_PCT", "FT%":
            valueStr = String(format: "%.1f", (player.ft_pct ?? -1) * 100)
        case "OREB":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.oreb ?? -1)
        case "DREB":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.dreb ?? -1)
        case "REB":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.reb ?? -1)
        case "AST":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.ast ?? -1)
        case "STL":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.stl ?? -1)
        case "BLK":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.blk ?? -1)
        case "TOV":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.tov ?? -1)
        case "EFF":
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.eff ?? -1)
        default:
            valueStr = String(format: isTotal ? "%.0f" : "%.1f", player.pts ?? -1)
        }
        
        return valueStr
    }
}


#Preview {
    PlayerRowView(player: Player.demoPlayer, rowType: "players").environmentObject(PlayerDataManager())
}
