//
//  SoundsManager.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/25/23.
//

import Foundation
import AVFoundation

var audioPlayer : AVAudioPlayer!

class SoundsManager: ObservableObject {
    // Sound will not play in simulator.
    // Apparently, this is a bug that has not been addressed.
    // An error will show in the console, but the app will continue to run.
    func playSound(soundFile: String) {
        let settingsManager = SettingsManager()
        let sound = settingsManager.settingsDict["soundPref"] as? Bool ?? true
        
        if sound {
            let path = Bundle.main.path(forResource: soundFile, ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                //create your audioPlayer in your parent class as a property
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
            } catch {
                print("couldn't load the file")
            }
        }
    }
}
