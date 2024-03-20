//
//  Tab.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/7/23.
//

import SwiftUI

struct TabItem: Identifiable {
    var id = UUID()
    var text: String
    var icon: String
    var tab: Tab
    var color: Color
}

var tabItems = [
    TabItem(text: "Home", icon: "sportscourt", tab: .home, color: .teal),
    TabItem(text: "Favorites", icon: "heart", tab: .favorites, color: .orange),
    TabItem(text: "Settings", icon: "image", tab: .settings, color: .cyan)
]

enum Tab: String {
    case home
    case favorites
    case settings
}

struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
