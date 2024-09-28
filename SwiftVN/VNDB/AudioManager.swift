//
//  AudioManager.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Foundation

class AudioManager: Loadable {
    private var archiveManager: ArchiveManager?
    
    private let sound = VLCMediaPlayer()
    private let music = VLCMediaPlayer()
    
    private var soundStream: InputStream?
    private var musicStream: InputStream?
    
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
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoadEvent), name: .loadEvent, object: nil)
    }
    
    @objc func handleLoadEvent(_ notification: Notification) {
        loadHandler()
    }
    
    func loadHandler() {
        print("Loading sound...")
        archiveManager = ArchiveManager(zipFileName: "sound.zip")
        print("archiveManager: \(String(describing: archiveManager))")
    }
 
    func clearMusic() {
        music.stop()
    }
    
//    func clearSound() {
//        sound.stop()
//    }
//    
//    func loadSound(path: String) {
//        guard let url = Bundle.main.url(forResource: path, withExtension: nil) else {
//            print("Sound file not found")
//            return
//        }
//        
//        sound.media = VLCMedia(url: url)
//        
//        if (sound.media == nil) {
//            print("Error loading audio source for sound file path \(path)")
//            return
//        }
//    }
//    
//    func loadSound(data: Data) {
//        sound.media = VLCMedia(stream: InputStream(data: data))
//        
//        if (sound.media == nil) {
//            print("Error loading audio source for sound data")
//            return
//        }
//    }
//    
//    func playSound() {
//        if (sound.isPlaying) {
//            clearSound()
//        }
//        
//        sound.play()
//        sound.audio?.volume = soundVolume
//    }
    
    func loadMusic(path: String) {
        var soundsPath = SwiftVN.baseDirectory.appendingPathComponent("sound")
        
        // Load the audio source
        let soundUrl = soundsPath.appendingPathComponent(path)
        
        let fm = FileManager.default
        if !fm.fileExists(atPath: soundUrl.path, isDirectory: nil) {
            print("File does not exist")
            return
        }

        music.media = VLCMedia(url: soundUrl)
        
        if (music.media == nil) {
            print("Error loading audio source for music file path \(soundUrl.path)")
            return
        }
    }
    
    func loadMusic(title: String) {
        let data = archiveManager?.extractFile(named: "sound/music/\(title)")
        if data == nil {
            print("Error loading music file")
            return
        }
        
        musicStream = InputStream(data: data!)
        if musicStream == nil {
            print("Error creating music stream")
            return
        }
        
        musicStream?.open()
        music.media = VLCMedia(stream: musicStream!)
    }
    
    func loadMusic(data: Data) {
        music.media = VLCMedia(stream: InputStream(data: data))
        
        if (music.media == nil) {
            print("Error loading audio source for music data")
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
