//
//  SettingsView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 3/4/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var soundsManager: SoundsManager
    
    @Binding var showSignIn: Bool
    
    @State private var faveTeamID = Team.teamData[30].teamID
    
    @State private var userName = "StatBeast1234"
    @State private var editUserName = false
    @State private var teamAccentColor = true
    @State private var teamTabIcon = true
    @State private var playSounds = true
    
    @State private var team = Team.teamData[30]
    
    @State private var needSignIn = false
    
    var signedUp: Bool {
        return authManager.authState == .signedIn
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                profile
                    .background(.ultraThinMaterial)
                
                List{
                    menu
                    links
                    resetBtn
                    logoutBtn
                }
                .listStyle(.insetGrouped)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Settings").bold().foregroundStyle(.tertiary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        settingsManager.showSettingsPage = false
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
        }
        .onAppear(perform: {
            if signedUp {
                let id = settingsManager.settingsDict["faveTeamID"] as? Int
                let un = settingsManager.settingsDict["userName"] as? String
                let ap = settingsManager.settingsDict["accentPref"] as? Bool
                let tp = settingsManager.settingsDict["tabbarPref"] as? Bool
                let sp = settingsManager.settingsDict["soundPref"] as? Bool
                
                faveTeamID = (id ?? team.teamID)
                team = Team.teamData.first(where: { $0.teamID == faveTeamID }) ?? Team.teamData[30]
                userName = un ?? "StatBeast1234"
                teamAccentColor = ap ?? true
                teamTabIcon = tp ?? true
                playSounds = sp ?? true
            } else {
                userName = "user\(authManager.user?.uid.suffix(7) ?? "1234")"
            }
        })
        .onDisappear(perform: {
            if needSignIn {
                showSignIn = true
            }
        })
    }
    
    var profile: some View {
        VStack() {
            Image(uiImage: faveTeamID == Team.teamData[30].teamID ? UIImage(named: "logo")! : team.logo)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .shadow(radius: 4)
                .padding(.top, 20)
            
            Text(userName)
                .font(.title.bold().italic())
            
            Label(locationManager.location ?? "unknown", systemImage: "location")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            if signedUp {
                editUserName = true
            }
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
        Section(header: VStack { if !signedUp {
            Text("Sign up for customization options")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        } }) {
            Menu {
                Picker("Favorite Team", selection: $faveTeamID) {
                    ForEach(Team.teamData, id: \.teamID) { t in
                        Label {
                            Text(t.fullName)
                        } icon: {
                            Image(uiImage: t.logo)
                        }
                    }
                }
                .frame(maxHeight: 20)
                .onChange(of: faveTeamID) {
                    team = Team.teamData.first(where: { $0.teamID == faveTeamID }) ?? Team.teamData[30]
                    settingsManager.settingsDict["faveTeamID"] = faveTeamID
//                    settingsManager.favTeam = team
//                    settingsManager.favTeamID = faveTeamID
//                    myTeamID = faveTeamID
                    settingsManager.save()
                }
            } label: {
                HStack {
                    Image(uiImage: team.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 30)
                    Spacer()
                    
                    Text(team.fullName)
                    
                    Image(systemName: "chevron.up.chevron.down")
                }
            }
            .disabled(!signedUp)
            
            Toggle(isOn: $teamAccentColor) {
                Text("Favorite team accent color")
            }
            .disabled(!signedUp)
            .onChange(of: teamAccentColor) {
                settingsManager.settingsDict["accentPref"] = teamAccentColor
                settingsManager.save()            }
            
            Toggle(isOn: $teamTabIcon) {
                Text("Favorite team logo tab bar")
            }
            .disabled(!signedUp)
            .onChange(of: teamTabIcon) {
                settingsManager.settingsDict["tabbarPref"] = teamTabIcon
                settingsManager.save()
            }
            
            Toggle(isOn: $playSounds) {
                Text("Play sound effects")
            }
            .onChange(of: playSounds) {
                settingsManager.settingsDict["soundPref"] = playSounds
                settingsManager.save()
                
                if playSounds {
                    soundsManager.playSound(soundFile: "success")
                }
            }
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
    
    var resetBtn: some View {
        Section {
            Button("Reset Settings") {
                withAnimation {
                    settingsManager.reset()
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(!signedUp)
        }
    }
    
    var logoutBtn: some View {
        Section {
            Button(signedUp ? "Sign Out" : "Sign Up") {
                withAnimation {
                    if signedUp {
                        signOut()
                    } else {
                        settingsManager.showSettingsPage = false
                        needSignIn = true
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color(signedUp ? .red : .blue))
            .foregroundStyle(.white)
        }
    }
    
    func signOut() {
        Task {
            do {
                try await authManager.signOut()
                settingsManager.showSettingsPage = false
                needSignIn = true
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView(showSignIn: .constant(true)).environmentObject(AuthManager()).environmentObject(SettingsManager()).environmentObject(LocationManager()).environmentObject(SoundsManager())
}
