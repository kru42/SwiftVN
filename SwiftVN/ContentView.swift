//
//  ContentView.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import SwiftUI
import SpriteKit
import Logging

// SwiftUI View
struct ContentView: View {
    private let vn: SwiftVN = SwiftVN()
    private let audioManager: AudioManager = AudioManager()
    private let spriteManager = SpriteManager()
    
    private let logger = LoggerFactory.shared

    init() {
        vn.prepareAssets()
    }
    
    var body: some View {
        ZStack {
            if spriteManager.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5, anchor: .center)
            } else {
                CustomSpriteView(spriteManager: spriteManager) // Use your custom view
                    .ignoresSafeArea() // Make it cover the full screen
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if SpriteManager.hasLoaded {
                                logger.info("Loading background and images...")
                                spriteManager.loadBackground(path: "ba05no1.jpg", withAnimationFrames: 60)
                                spriteManager.setForegroundImage(fileName: "fumi02.png", x: 60, y: 0)
                            }
                        }
                        
                        audioManager.loadMusic(songPath: "music/s02.mp3")
                        audioManager.playMusic()
                    }
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
