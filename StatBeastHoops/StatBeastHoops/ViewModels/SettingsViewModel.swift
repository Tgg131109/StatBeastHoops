//
//  SettingsViewModel.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/7/24.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var settingsDict : [String : Any] = ["userName" : "StatGod87", "faveTeamID" : 15, "soundPref": false]
    @Published var favTeam : Team = Team.teamData[30]
    @Published var favTeamID : Int = Team.teamData[30].teamID
//    @Published var showSettingsPage = false
    
    // Keys used to write to UserDefaults
    private let saveSettingsKey = "UserSettings"
    
    init() {
        // Here we need to decode the objects into either a set or array to populate get usable data
        // load user's saved player objects
        if let uData = UserDefaults.standard.dictionary(forKey: saveSettingsKey) {
            if let userName = uData["userName"] {
                settingsDict["userName"] = userName
            }
            
            if let faveTeamID = uData["faveTeamID"] {
                settingsDict["faveTeamID"] = faveTeamID
            }
            
            if let soundPref = uData["soundPref"] {
                settingsDict["soundPref"] = soundPref
            }
        }
    }
    
    func save() {
        // write out save data to user defaults
        // need to encode set first since we're not using an array of int
        UserDefaults.standard.set(settingsDict, forKey: saveSettingsKey)
    }
}
