//
//  ZAudioPlayer.swift
//  FidgetWidget
//
//  Created by Zain Haider on 18/02/2021.
//  Copyright © 2021 DevStudio. All rights reserved.
//

import AVFoundation

class ZHAudio: NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = ZHAudio()
    
    private override init() {}
    
    var players = [NSURL:AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    
    func playSound (soundFilePath: String){
        
        let soundFileNameURL = NSURL(fileURLWithPath: soundFilePath)
        
        if let player = players[soundFileNameURL] { //player for sound has been found
            if player.isPlaying == false { //player is not in use, so use that one
                player.prepareToPlay()
                player.play()
            } else { // player is in use, create a new, duplicate, player and use that instead
                do {
                    let duplicatePlayer = try AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                    //use 'try!' because we know the URL worked before.
                    duplicatePlayer.delegate = self
                    //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                    duplicatePlayers.append(duplicatePlayer)
                    //add duplicate to array so it doesn't get removed from memory before finishing
                    duplicatePlayer.prepareToPlay()
                    duplicatePlayer.play()
                } catch (let error) {
                    print(error.localizedDescription)
                }
            }
        } else { //player has not been found, create a new player with the URL if possible
            do{
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                players[soundFileNameURL] = player
                player.prepareToPlay()
                player.play()
            } catch {
                print("Could not play sound file!")
            }
        }
    }
    
    
    func playSounds(soundFileNames: [String]){
        for soundFileName in soundFileNames {
            playSound(soundFilePath: soundFileName)
        }
    }
    
    func playSounds(soundFileNames: String...){
        for soundFileName in soundFileNames {
            playSound(soundFilePath: soundFileName)
        }
    }
    
    func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
        for (index, soundFileName) in soundFileNames.enumerated() {
            let delay = withDelay*Double(index)
            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.playSoundNotification(notification:)), userInfo: ["fileName":soundFileName], repeats: false)
        }
    }
    
    @objc func playSoundNotification(notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFilePath: soundFileName)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let index = duplicatePlayers.index(of: player) else {return}
        duplicatePlayers.remove(at: index)
        //Remove the duplicate player once it is done
    }
    
}
