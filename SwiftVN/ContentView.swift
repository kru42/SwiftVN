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
    private var vn = SwiftVN()
    
    @StateObject private var audioManager = AudioManager()
    @StateObject private var sceneLoader = SceneLoader()
    @StateObject private var fpsCounter = FPSCounter()
    
    @State private var isSceneReady: Bool = false
    
    private let logger = LoggerFactory.shared
    
    var body: some View {
        ZStack {
            if sceneLoader.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5, anchor: .center)
            } else if isSceneReady {
                SpriteView(scene: sceneLoader.getScene())
                    .ignoresSafeArea()
                    .onAppear {
                        logger.info("SpriteView displayed.")
                    }
                    .onTapGesture {
                        sceneLoader.getScene().handleTap()
                    }
            }
            
            // Overlay for title and FPS
            VStack {
                HStack {
                    Text("SwiftVN 0.1")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    Spacer()
                    TimelineView(.animation) { timeline in
                        let _ = DispatchQueue.main.async {
                            fpsCounter.update(date: timeline.date)
                        }
                        
                        Text("FPS: \(Int(fpsCounter.fps))")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                }
                .background(Color.black.opacity(0.5))
                
                Spacer() // This spacer pushes the HStack to the top
            }
        }
        .onAppear {
            initScene()
            
            NotificationCenter.default.addObserver(forName: .sceneReady, object: nil, queue: .main) { _ in
                let scene = sceneLoader.getScene()
                logger.info("Loading test background and images...")
                
                scene.loadBackground(path: "ba05no1.jpg", withAnimationFrames: 60)
                scene.setForegroundImage(fileName: "yoh05.png", x: 10, y: 0)
                
                audioManager.loadMusic(songPath: "music/s02.mp3")
                // audioManager.playMusic()
                
                logger.info("Drawing some text...")
                
                //logger.info("SwiftVN 0.1 loaded")
            }
        }
    }
    
    private func initScene() {
        vn.prepareAssets()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if SceneLoader.hasLoaded && AudioManager.hasLoaded {
                self.isSceneReady = true
            }
        }
    }
}

class FPSCounter: ObservableObject {
    @Published var fps: Double = 0
    private var lastUpdateTime = Date()
    private var frameCount = 0
    
    func update(date: Date) {
        frameCount += 1
        let elapsed = date.timeIntervalSince(lastUpdateTime)
        if elapsed >= 1 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            lastUpdateTime = date
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
