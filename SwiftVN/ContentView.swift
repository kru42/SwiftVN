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
    @StateObject private var fpsCounter = FPSCounter()
    
    private var vn = SwiftVN()
    @State private var scene: NovelScene? = nil
    @State private var showHistoryOverlay = false
    
    private let logger = LoggerFactory.shared
    
    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                // Adjust the y-coordinate before passing it to the SK scene
                                let adjustedY = UIScreen.main.bounds.height - value.location.y
                                let adjustedLocation = CGPoint(x: value.location.x, y: adjustedY)
                                scene.handleTap(at: adjustedLocation)
                            }
                    )
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
                    
                    Button(action: {
                        _ = scene?.saveLoadManager?.loadState(slot: 0)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        _ = scene?.saveLoadManager?.saveState(slot: 0)
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showHistoryOverlay.toggle()
                        scene?.toggleHistoryOverlay()
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.white)
                            .cornerRadius(10) // FIXME: deprecated
                    }
                    
                    Button(action: {
                        scene?.toggleSkip()
                    }) {
                        Image(systemName: "forward.fill")
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .cornerRadius(10)
                    }
                }
                .background(Color.black.opacity(0.5))
                
                Spacer() // This spacer pushes the HStack to the top
            }
            .onAppear {
                if scene == nil {
                    let newScene = NovelScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                    newScene.scaleMode = . aspectFill
                    self.scene = newScene
                    newScene.next()
                }
            }
            
            if scene?.executor?.isLoadingMusic == true {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .foregroundStyle(.white)
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
