//
//  AppManager.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 4/16/24.
//

import Foundation

@MainActor
class AppManager : ObservableObject {
    @Published var apiManager = DataManager()
    @Published var teamDataManager = TeamDataManager()
    @Published var playerDataManager = PlayerDataManager()
    @Published var favoritesManager = FavoritesManager()
    @Published var settingsManager = SettingsManager()
    @Published var locationManager = LocationManager()
    @Published var soundsManager = SoundsManager()
    @Published var playerCompareVM = PlayerCompareViewModel()
    
    @Published var showSettingsPage = false
    @Published var showCompareSetup = false
}
