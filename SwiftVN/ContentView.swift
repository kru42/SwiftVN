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
    
    @State private var isSceneReady: Bool = false
    @State private var fps: Double = 0.0
    @State private var lastUpdateTime: Date = Date()
    
    private let logger = LoggerFactory.shared
    
    var body: some View {
        ZStack {
            if sceneLoader.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                // .scaleEffect(1.5, anchor: .center)
            } else if isSceneReady {
                SpriteView(scene: sceneLoader.getScene())
                    .ignoresSafeArea()
                    .onAppear {
                        logger.info("SpriteView rendered")
                        
                        startFPSTimer()
                    }
            }
            
            // Overlay for title and FPS
            VStack {
                HStack {
                    Text("SwiftVN 0.1")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                    Spacer()
                    Text("FPS: \(Int(fps))")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                }
                .background(Color.black.opacity(0.5)) // Semi-transparent black background
                .padding() // Optional padding around the HStack
                Spacer() // This spacer pushes the HStack to the top
            }
        }
        .onAppear {
            initScene()
            
            NotificationCenter.default.addObserver(forName: .sceneReady, object: nil, queue: .main) { _ in
                let scene = sceneLoader.getScene()
                logger.info("Loading test background and images...")
                
                scene.loadBackground(path: "ba05no1.jpg", withAnimationFrames: 60)
                scene.setForegroundImage(fileName: "fumi02.png", x: 60, y: 0)
                
                audioManager.loadMusic(songPath: "music/s02.mp3")
                audioManager.playMusic()
                
                logger.info("Drawing some text...")
                
                scene.renderTextLineWithAnimation("ハハ、勘煕ﾋヤッテクレヨ津久葉。コイツ今ｴﾋ?ｱ角咨まッテンダ。ナンｶｵノ前、コｭナッテ始メテすけーﾑﾜﾕｱ性ﾀ縷ンダカラサ")
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
    
    private func startFPSTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let currentTime = Date()
            let elapsed = currentTime.timeIntervalSince(lastUpdateTime)
            if elapsed > 0 {
                fps = 1.0 / elapsed
            }
            
            lastUpdateTime = currentTime
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
