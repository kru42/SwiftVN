//
//  VNScene.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SpriteKit

class NovelScene: SKScene, ObservableObject {
    private var executor: ScriptExecutor?
    
    var textManager: TextManager?
    var spriteManager: SpriteManager?
    
    var audioManager = AudioManager()

    override func didMove(to view: SKView) {
        backgroundColor = .gray
        
        // Instantiate or re-instantiate UI elements and scripts
        textManager = TextManager(scene: self)
        spriteManager = SpriteManager(scene: self)
        
        executor = ScriptExecutor(scene: self)
        executor?.loadScript(named: "s02.scr")
    }
    
    func next() {
        executor?.next()
    }
}
