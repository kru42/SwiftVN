//
//  AudioManager.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Logging

class AudioManager: Loadable {
    private var archiveManager: ArchiveManager?
    static var hasLoaded = false // TODO: UNUSED
    
    private let sound = VLCMediaPlayer()
    private let music = VLCMediaPlayer()
    
    private var soundStream: InputStream?
    private var musicStream: InputStream?
    
    private var soundVolume: Int32 = 100
    private var musicVolume: Int32 = 100
    
    private let logger = LoggerFactory.shared
    
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
        logger.info("Opening sounds ZIP...")
        archiveManager = ArchiveManager(zipFileName: "sound.zip")
    }
 
    func clearMusic() {
        music.stop()
    }
    
    func clearSound() {
        sound.stop()
    }
    
    // TODO: Account for second numeric argument to opcode `sound`
    func loadSound(soundPath: String) {
        let data = archiveManager?.extractFile(named: "sound/\(soundPath)")
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

    func loadMusic(path: String) {
        var soundsPath = SwiftVN.baseDirectory.appendingPathComponent("sound")
        
        // Load the audio source
        let songUrl = soundsPath.appendingPathComponent(path)
        
        let fm = FileManager.default
        if !fm.fileExists(atPath: songUrl.path, isDirectory: nil) {
            print("File does not exist")
            return
        }

        music.media = VLCMedia(url: songUrl)
        
        if (music.media == nil) {
            print("Error loading audio source for music file path \(songUrl.path)")
            return
        }
    }
    
    func loadMusic(songPath: String) {
        let data = archiveManager?.extractFile(named: "sound/\(songPath)")
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