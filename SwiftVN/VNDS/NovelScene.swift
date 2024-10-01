//
//  VNScene.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SpriteKit

// more like LeakalotScene
class NovelScene: SKScene, ObservableObject {
    var executor: ScriptExecutor?
    var textManager: TextManager?
    var spriteManager: SpriteManager?
    var historyOverlay: HistoryOverlayNode!
    
    var audioManager = AudioManager()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Instantiate or re-instantiate UI elements and scripts
        let textNode = TextNode(fontSize: 16, maxLines: 10, padding: 12)
        
        textManager = TextManager(scene: self, textNode: textNode)
        spriteManager = SpriteManager(scene: self)
        
        historyOverlay = HistoryOverlayNode(size: self.size)
        historyOverlay.isHidden = true
        
        executor = ScriptExecutor(scene: self)
        executor?.loadScript(named: "main.scr")
        
        // Start the script
        executor?.next()
    }
    
    func handleTap(at location: CGPoint) {
        executor?.handleTap(at: location)
    }
    
    func next() {
        executor?.next()
    }
    
    func toggleHistoryOverlay() {
        historyOverlay.isHidden.toggle()
    }
    
    func toggleSkip() {
        executor?.skip.toggle()
    }
}

