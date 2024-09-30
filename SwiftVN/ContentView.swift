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
    
    private let logger = LoggerFactory.shared
    
    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .onTapGesture {
                        scene.next()
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
            .onAppear {
                if scene == nil {
                    let newScene = NovelScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                    newScene.scaleMode = . aspectFill
                    self.scene = newScene
                    newScene.next()
                }
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
