//
//  TeamDetailView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/11/24.
//

import SwiftUI
import Charts

struct TeamDetailView: View {
    @StateObject var apiManager: DataManager
    @StateObject var playerDataManager : PlayerDataManager
    
    @State var isFav = false
    @State private var season = "2023-24"
    @State private var selView = 0
    @State var r = [Player]()
    
    let team: Team
    
    var body: some View {
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
                            
                            Text(team.homeTown)
                            Text(team.teamName).font(.largeTitle).fontWeight(.black).padding(.top, -20)
                            Text(team.record).fontWeight(.heavy)
                            Text(team.standing).font(.caption)
                        }.frame(maxHeight: 170)
                        
                        Spacer()
                        
                        Image(uiImage: team.logo).resizable().aspectRatio(contentMode: .fill).frame(width: 100, height: 250).shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }.padding(.horizontal, 20)
                }.padding(.bottom, -80)
                
                Picker("Season", selection: $season) {
                    ForEach(apiManager.seasons, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .background(.regularMaterial).clipShape(.capsule)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 20)
                .onChange(of: season) {
//                    apiManager.getChartData(criteria: criteria, pIDs: ["\(p1ID)", "\(p2ID)"])
                }
                
                Picker("View", selection: $selView) {
                    Text("Season").tag(0)
                    Text("Roster").tag(1)
                    Text("Stats").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                
                if selView == 0 {
                    
                } else if selView == 1 {
                    List{
                        ForEach(r, id: \.playerID) { player in
                            PlayerRowView(playerDataManager: playerDataManager, player: player, rowType: "roster")
                        }
                    }
                    .listStyle(.plain)
                } else {
                    Text(team.fullName)
                }

                Spacer()
                
                Text(team.fullName)
            }
            .navigationTitle(team.abbr)
            .toolbarTitleDisplayMode(.inline)
        }.onAppear(perform: {   Task{
            r = await apiManager.getTeamRoster(teamID: "\(team.teamID)")
        } })
    }
}

#Preview {
    TeamDetailView(apiManager: DataManager(), playerDataManager: PlayerDataManager(), team: Team.teamData[15])
}
