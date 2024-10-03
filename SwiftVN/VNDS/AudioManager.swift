//
// AudioManager.swift
//

class AudioManager: ObservableObject {
    static var hasLoaded = false
    
    private var musicPlayer = VLCMediaPlayer()
    private var musicStreams: [InputStream] = []
    
    private var soundPlayer = VLCMediaPlayer()
    // FIXME: Don't leak streams pls
    private var soundStreams: [InputStream] = []

    // Only support one looping sound playing at the moment
    private var loopPlayer = VLCMediaPlayer()
    private var loopStream: InputStream?
    
    private var soundVolume: Int32 = 100
    private var musicVolume: Int32 = 50
    
    private var archiveManager = ArchiveManager(zipFileName: "sound.zip")
    private let logger = LoggerFactory.shared
    
    var currentMusicPath: String?

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
    
    func clearMusic() {
        if musicPlayer.isPlaying {
            musicPlayer.stop()
        }
    }
    
    func clearSound() {
        if soundPlayer.isPlaying {
            soundPlayer.stop()
        }
    }
    
    func clearLoop() {
        if loopPlayer.isPlaying {
            loopPlayer.stop()
        }
    }
    
    func playSound(soundPath: String, loop: Bool = false) {
        archiveManager.extractFile(named: "sound/\(soundPath)") { data in
            if data == nil {
                self.logger.error("Error loading sound file")
                return
            }
            
            let stream = InputStream(data: data!)
            guard let media = VLCMedia(stream: stream) else {
                self.logger.critical("Failed to create VLCMedia for sound")
                return
            }
            self.soundStreams.append(stream)
            
            if loop {
                self.clearLoop()
                
                self.loopPlayer.media = media
                self.loopPlayer.audio?.volume = self.soundVolume
                
                // TODO: Loop
                self.loopPlayer.play()
                return
            }
            
            self.clearSound()
            
            self.soundPlayer.media = media
            self.soundPlayer.audio?.volume = self.soundVolume
            
            self.soundPlayer.play()
        }
    }
    
    func playMusic(songPath: String, completion: @escaping () -> Void) {
        self.archiveManager.extractFile(named: "sound/\(songPath)") { data in
            if data == nil {
                self.logger.error("Error loading music file")
                return
            }
            
            let stream = InputStream(data: data!)
            guard let media = VLCMedia(stream: stream) else {
                self.logger.critical("Failed to create VLCMedia for music")
                return
            }
            
            self.currentMusicPath = "sound/\(songPath)"
            
            self.musicStreams.append(stream)
            
            self.clearMusic()
            
            self.musicPlayer.media = media
            self.musicPlayer.audio?.volume = self.musicVolume
            
            self.musicPlayer.play()
            
            completion()
        }
    }
}
