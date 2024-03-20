//
//  Conditions.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/13/23.
//

import Foundation

struct Condition {
    var conditionID: UUID
    var stat: String
    var threshold: Int
}

extension Condition {
    static let firstCondition : Condition = Condition(conditionID: UUID(uuidString: UUID().uuidString)!, stat: "Points", threshold: 50)
}
