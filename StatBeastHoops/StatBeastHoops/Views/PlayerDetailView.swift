//
//  PlayerDetailView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/12/24.
//

import SwiftUI

struct PlayerDetailView: View {
    @StateObject var apiManager : DataManager
    
    @State var isFav = false
    @State private var season = "2023-24"
    @State private var selView = 0
    
    let p : Player
    
    var body: some View {
        let team = p.team
        let pc = team.priColor
        
        NavigationStack {
            VStack {
                ZStack {
                    Image(uiImage: team.logo).resizable().rotationEffect(.degrees(-35)).aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 250).overlay(Color(.systemBackground).opacity(0.8).frame(maxWidth: .infinity, maxHeight: 250))
                        .clipped().padding(.trailing, -200).ignoresSafeArea()
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Button {
                                isFav.toggle()
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
                        Text("\(p.height ?? "-1")").bold()
                        Text("PPG").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                    
//                    Divider()
                    
                    VStack {
                        Text("\(p.weight ?? "-1")").bold()
                        Text("RPG").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                    
//                    Divider()
                    
                    VStack {
                        Text("\(p.age ?? 0)").bold()
                        Text("APG").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                    
//                    Divider()
                    
                    VStack {
                        Text("\(p.age ?? 0)").bold()
                        Text("FANT").font(.caption2)
                    }.frame(maxWidth:  .infinity).foregroundStyle(.background).padding(.vertical, 10).border(.background)
                }.background(Color(pc)).frame(maxHeight: 30).padding(.top,8)
                
                // Player info section
                HStack(spacing: 0) {
                    VStack {
                        Text("\(p.attr)").font(.caption).bold()
                    }.frame(maxWidth: .infinity).foregroundStyle(Color(pc))
                    
                    Divider().frame(maxWidth: 1).overlay(Color(pc)).padding(.vertical, -8)
                    
                    VStack {
                        Text("\(p.draft)").font(.caption).bold()
                        Text("Draft").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(Color(pc))
                }.frame(maxHeight: 15).padding(.top).padding(.bottom, 4)
                
                Divider().frame(maxHeight: 1).overlay(Color(pc)).padding(.horizontal, 4)
                
                HStack(spacing: 0) {
                    VStack {
                        Text("\(p.birthDate ?? "-")").font(.caption).bold()
                        Text("Birthday").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(Color(pc))
                    
                    Divider().frame(maxWidth: 1).overlay(Color(pc)).padding(.vertical, -8)
                    
                    VStack {
                        Text("\(p.country ?? "-1")").font(.caption).bold()
                        Text("Country").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(Color(pc))
                }.frame(maxHeight: 15).padding(.vertical, 4)
                
                Divider().frame(maxHeight: 1).overlay(Color(pc)).padding(.horizontal, 4)
                
                HStack(spacing: 0) {
                    VStack {
                        Text("\(p.college ?? "-")").font(.caption).bold()
                        Text("School").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(Color(pc))
                    
                    Divider().frame(maxWidth: 1).overlay(Color(pc)).padding(.vertical, -8)
                    
                    VStack {
                        Text("\(p.exp ?? "-1")").font(.caption).bold()
                        Text("Experience").font(.caption2)
                    }.frame(maxWidth: .infinity).foregroundStyle(Color(pc))
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
                    
                } else if selView == 1 {
                    
                } else {
                    Text(p.lastName)
                }
                
                Spacer()
                
                Text(p.lastName)
            }.toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(team.homeTown).bold().padding(.trailing, -10)
                        Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 50, alignment: .center)
                        Text(team.teamName).bold().padding(.leading, -10)
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }.onAppear(perform: {   Task{
//            r = await apiManager.getTeamRoster(teamID: "\(team.teamID)")
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
}

#Preview {
    PlayerDetailView(apiManager: DataManager(), p: Player.demoPlayer)
}
