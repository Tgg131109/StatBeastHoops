//
//  SettingsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var apiManager : DataManager
    @EnvironmentObject var settingsManager : SettingsManager
    @EnvironmentObject var locationManager : LocationManager
    @EnvironmentObject var soundsManager : SoundsManager
    
    @State private var teams = Team.teamData
    @State private var faveTeamID = Team.teamData[30].teamID
    @State private var playSounds = true
    @State private var userName = "Hooper1234"
    @State private var editUserName = false
    @State private var team = Team.teamData[30]
    
    @Binding var myTeamID : Int
    
    var body: some View {
        NavigationView {
            List{
                menu
                links
            }
            .listStyle(.insetGrouped)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 230)
            })
            .safeAreaInset(edge: .bottom, content: {
                Color.clear.frame(height: 70)
            })
        }
        // Custom navigation header.
        .overlay(
            ZStack {
//                SettingsHeaderView(team: Team.teamData[faveTeamID - 1])
                
                Color(UIColor.systemBackground).opacity(0.7)
                    .ignoresSafeArea()
                
                profile
                
//                HeaderTextView(section: "Settings")
//                    .frame(maxHeight: .infinity, alignment: .top)
            }
                .frame(height: 260)
                .frame(maxHeight: .infinity, alignment: .top)
        )
        .onAppear(perform: {
            let id = settingsManager.settingsDict["faveTeamID"] as? Int
            let un = settingsManager.settingsDict["userName"] as? String
            let sp = settingsManager.settingsDict["soundPref"] as? Bool

            faveTeamID = (id ?? team.teamID)
            team = Team.teamData.first(where: { $0.teamID == faveTeamID }) ?? Team.teamData[30]
            userName = un ?? "Hooper1234"
            playSounds = sp ?? true
        })
    }
    
    var profile: some View {
        VStack(spacing: 8) {
            Image(uiImage: team.logo)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(50)
//                .borderRadius(Color(UIColor.systemOrange), width: 4, cornerRadius: 50, corners: .allCorners)
                .shadow(radius: 4)
                .padding(.top, 20)
            
            
            Text(userName)
                .font(.title.bold().italic())
            
            Label(locationManager.location ?? "unknown", systemImage: "location")
                .font(.title2)
                .foregroundColor(Color(UIColor.secondaryLabel))
//            HStack {
//                Image(systemName: "location")
//                    .imageScale(.large)
//                Text(locationManager.location ?? "unknown")
//                    .font(.title2)
//                    .foregroundColor(.secondary)
//            }
            .padding(.bottom, -50)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            editUserName = true
        }
        .alert("Edit Username", isPresented: $editUserName) {
            TextField(userName, text: $userName).multilineTextAlignment(.center)
            
            Button("OK", action: {
                settingsManager.settingsDict["userName"] = userName
                settingsManager.save()
            })
        } message: {
            Text("What should we call you?")
        }
    }
    
    var menu: some View {
        Section {
            Menu {
                Picker("Favorite Team", selection: $faveTeamID) {
                    ForEach(Team.teamData, id: \.teamID) { t in
                        Label {
                            Text(t.fullName)
                        } icon: {
                            Image(uiImage: t.logo)
                        }
                        //                    HStack {
                        //                        Image(uiImage: t.logo)
                        //                            .resizable()
                        //                            .frame(maxWidth: 20)
                        ////                            .frame(width: 20, height: 20)
                        //                            .aspectRatio(contentMode: .fit)
                        ////                            .scaledToFill()
                        //
                        //                        Text(t.fullName)
                        //                    }
                    }
                }
                .frame(maxHeight: 20)
                //            .pickerStyle(.menu)
                .onChange(of: faveTeamID) {
//                    print(faveTeamID)
                    team = Team.teamData.first(where: { $0.teamID == faveTeamID }) ?? Team.teamData[30]
                    settingsManager.settingsDict["faveTeamID"] = faveTeamID
//                    settingsManager.favTeam = team
//                    settingsManager.favTeamID = faveTeamID
                    myTeamID = faveTeamID
                    settingsManager.save()
                }
            } label: {
                HStack {
                    Image(uiImage: team.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 50, height: 20)
                        .frame(maxWidth: 30)
                    Spacer()
                    
                    Text(team.fullName)
                    
                    Image(systemName: "chevron.up.chevron.down")
                }
//                .tint(.secondary)
//                .imageScale(.small)
            }
            
            Toggle(isOn: $playSounds) {
                Text("Play sound effects")
            }
            .tint(Color(UIColor.systemTeal))
            .onChange(of: playSounds, perform: { newValue in
                settingsManager.settingsDict["soundPref"] = newValue
                settingsManager.save()
                
                if playSounds {
                    soundsManager.playSound(soundFile: "success")
                }
            })
        }
        .accentColor(.primary)
        .listRowSeparatorTint(.blue)
        .listRowSeparator(.hidden)
    }
    
    var links: some View {
        Section {
            Link(destination: URL(string: "https://www.nba.com/stats")!) {
                HStack {
                    Label("NBA.com", systemImage: "house")
                    Spacer()
                    Image(systemName: "link")
                        .foregroundColor(.secondary)
                }
            }
        }
        .accentColor(.primary)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    SettingsView(myTeamID: .constant(Team.teamData[30].teamID))
}
