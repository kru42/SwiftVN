//
//  AudioManager.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Foundation
import AVFoundation

class AudioManager {
    private var sound = VLCMediaPlayer()
    private var music = VLCMediaPlayer()
    private var soundVolume: Int32 = 100
    private var musicVolume: Int32 = 100
    
    private let fileType: [String: String] = [
        "audio/x-aiff": "aiff",
        "audio/x-flac": "flac",
        "audio/mp4": "m4a",
        "audio/x-matroska": "mka",
        "audio/mpeg": "mp3",
        "audio/vorbis": "ogg",
        "audio/ogg": "ogg",
        "audio/x-wav": "wav",
        "audio/webm": "webm",
        "audio/x-ms-wma": "wma"
    ]
 
    private func clearMusic() {
        music.stop()
    }
    
    private func clearSound() {
        sound.stop()
    }
    
    func loadSound(path: String) {
        guard let url = Bundle.main.url(forResource: path, withExtension: nil) else {
            print("Sound file not found")
            return
        }
        
        sound.media = VLCMedia(url: url)
        
        if (sound.media == nil) {
            print("Error loading audio source for path \(path)")
            return
        }
    }
    
    func playSound() {
        if (sound.isPlaying) {
            clearSound()
        }
        
        sound.play()
        sound.audio?.volume = soundVolume
    }
    
    func loadMusic(path: String) {
        // Load the audio source
        guard let url = Bundle.main.url(forResource: path, withExtension: nil) else {
            print("Music file not found")
            return
        }
            
        music.media = VLCMedia(url: url)
        
        if (music.media == nil) {
            print("Error loading audio source for path \(path)")
            return
        }

    }
    
    func playMusic() {
        if (music.isPlaying) {
            clearMusic()
        }
        
        // TODO: Implement looping (VLCKit only supports it through VLCMediaListPlayer)
        music.play()
        music.audio?.volume = musicVolume
    }
}
