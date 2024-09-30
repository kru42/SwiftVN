class AudioManager: ObservableObject {
    static var hasLoaded = false
    
    private let music = VLCMediaPlayer()
    private var musicStream: InputStream?
    
    private var soundStreams: [InputStream] = []
    private var soundPlayer = VLCMediaPlayer()
    
    private var soundVolume: Int32 = 100
    private var musicVolume: Int32 = 50
    
    private var archiveManager = ArchiveManager(zipFileName: "sound.zip")
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
    
    func clearMusic() {
        music.stop()
    }
    
    func clearSound() {
        soundPlayer.stop()
    }
    
    func playSound(soundPath: String) {
        let data = archiveManager.extractFile(named: "sound/\(soundPath)")
        if data == nil {
            logger.error("Error loading sound file")
            return
        }
        
        let soundStream = InputStream(data: data!)
        guard let media = VLCMedia(stream: soundStream) else {
            logger.critical("Failed to create VLCMedia for sound")
            return
        }
        soundStreams.append(soundStream)

        clearSound()
        
        soundPlayer.media = media
        soundPlayer.audio?.volume = soundVolume
        
        soundPlayer.play()
    }
    
    func playMusic(songPath: String, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let data = self.archiveManager.extractFile(named: "sound/\(songPath)")
            if data == nil {
                self.logger.error("Error loading music file")
                return
            }
            
            self.musicStream = InputStream(data: data!)
            guard let media = VLCMedia(stream: self.musicStream!) else {
                self.logger.critical("Failed to create VLCMedia for music")
                return
            }
            
            self.music.media = media
            self.music.audio?.volume = self.musicVolume
            
            self.music.play()
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
