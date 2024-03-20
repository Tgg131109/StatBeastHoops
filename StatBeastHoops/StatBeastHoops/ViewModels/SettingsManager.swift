//
//  SettingsManager.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/23/23.
//

import Foundation

class SettingsManager: ObservableObject {
    @Published var settingsDict : [String : Any] = ["userName" : "StatGod87", "faveTeamID" : 15, "soundPref": false]
    
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
