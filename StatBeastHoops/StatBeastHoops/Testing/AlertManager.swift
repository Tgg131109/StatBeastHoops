//
//  AlertManager.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/19/23.
//

import Foundation
import SwiftUI

extension UIAlertController {
    func showAlert(title: String, message: String) {
        self.title = title
        self.message = message
        
        present(self, animated: true, completion: nil)
    }
}
