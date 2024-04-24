//
//  FavoritesManager.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/20/23.
//

import Foundation

class FavoritesManager: ObservableObject {
    // using sets instead of arrays to ensure no duplicate ids are saved in either group.
    // initialize each set as and empty array in case no favorites have been saved.
    private var players: [Player] = []
    private var teamIDs: Set<Int> = []

    // Keys used to write to UserDefaults
    private let savePlayerKey = "FavoritePlayers"
    private let saveTeamKey = "FavoriteTeams"
    
    init() {
        // Here we need to decode the objects into either a set or array to populate get usable data
        // load user's saved player objects
        if let pData = UserDefaults.standard.data(forKey: savePlayerKey) {
            if let decoded = try? JSONDecoder().decode([Player].self, from: pData) {
                players = decoded
            }
        }
        
        // load user's saved team ids
        if let tData = UserDefaults.standard.data(forKey: saveTeamKey) {
            if let decoded = try? JSONDecoder().decode(Set<Int>.self, from: tData) {
                teamIDs = decoded
            }
        }
    }

    // returns array of player objects = players array
    func getPlayers() -> [Player] {
        var p = [Player]()
        p = players
        return p
    }
    
    // returns array of team objects from teamIDs set
    func getTeams() -> [Team] {
        var teams = [Team]()
        
        for id in teamIDs {
            teams.append(Team.teamData.first(where: { $0.teamID == id }) ?? Team.teamData[30])
        }
        
        return teams
    }
    
    func getMatchups() -> [String] {
        return []
    }
    
    // returns true if our set contains the selected player
    func contains(_ player: Player) -> Bool {
        players.contains { $0.playerID == player.playerID }
    }

    // returns true if our set contains the selected team
    func contains(_ team: Team) -> Bool {
        teamIDs.contains(team.teamID)
    }
    
    // adds the playerID to our set, updates all views, and saves the change
    func add(_ player: Player) {
        objectWillChange.send()
        players.append(player)
        save(obj: "player")
    }

    // adds the teamID to our set, updates all views, and saves the change
    func add(_ team: Team) {
        objectWillChange.send()
        teamIDs.insert(team.teamID)
        save(obj: "team")
    }
    
    // removes the playerID from our set, updates all views, and saves the change
    func remove(_ player: Player) {
        objectWillChange.send()
        players.removeAll { $0.playerID == player.playerID }
        save(obj: "player")
    }

    // removes the teamID from our set, updates all views, and saves the change
    func remove(_ team: Team) {
        objectWillChange.send()
        teamIDs.remove(team.teamID)
        save(obj: "team")
    }
    
    func save(obj: String) {
        // write out save data to user defaults
        // need to encode set first since we're not using an array of int
        if obj == "player" {
            if let encoded = try? JSONEncoder().encode(players) {
                UserDefaults.standard.set(encoded, forKey: savePlayerKey)
            }
        } else {
            if let encoded = try? JSONEncoder().encode(teamIDs) {
                UserDefaults.standard.set(encoded, forKey: saveTeamKey)
            }
        }
    }
}
