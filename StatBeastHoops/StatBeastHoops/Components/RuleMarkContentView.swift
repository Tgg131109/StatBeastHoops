//
//  RuleMarkContentView.swift
//  StatBeastHoops
//
//  Created by Toby Gamble on 5/15/24.
//

import SwiftUI

struct RuleMarkContentView: View {
    let val: Double
    let criteria: String
    let matchup: String
    let gameDate: String
    
    var body: some View {
        VStack {
            if criteria.contains("%") {
                Text("\(String(format: "%.0f", (val) * 100))% \(criteria)")
            } else {
                Text("\(String(format: "%.0f", (val))) \(criteria)")
            }
            
            Text("\(matchup)")
            Text("\(getDateStr())")
        }
        .font(.footnote)
        .padding(6)
        .background(.ultraThinMaterial.opacity(0.2))
        .clipShape(.rect(cornerRadius: 16))
    }
    
    func getDateStr() -> String {
        let dateFormatter = DateFormatter()
        let convertDateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        convertDateFormatter.dateFormat = "MMM dd, yyyy"
        
        let date = dateFormatter.date(from:gameDate)!
        
        return convertDateFormatter.string(from: date)
    }
}

#Preview {
    RuleMarkContentView(val: 1.0, criteria: "PTS", matchup: "TM1 @ TM2", gameDate: "2024-01-01T00:00:00")
}
