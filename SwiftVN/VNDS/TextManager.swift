//
//  TextManager.swift
//  SwiftVN
//
//  Created by Kru on 30/09/24.
//

import SpriteKit

class TextManager {
    private let scene: SKScene
    
    var textNode: TextNode
    private let uiNode = SKNode()
    
    init(scene: SKScene) {
        self.scene = scene
        
        uiNode.zPosition = 1
        scene.addChild(uiNode)
        
        textNode = TextNode(fontSize: 16, maxLines: 10, padding: 10)
        textNode.position = CGPoint(x: 20, y: 20)
        uiNode.addChild(textNode)
    }
   
    // Returns true if next, false if skipped animation
    func setText(_ text: String) -> Bool {
        if textNode.isAnimating {
            textNode.skipAnimation()
            return false
        } else if textNode.isAnimationComplete {
            textNode.setTextWithAnimation(text)
            return true
        }
        
        fatalError("no")
    }
}
