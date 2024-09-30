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
    
    init(scene: SKScene, textNode: TextNode = TextNode(fontSize: 16, maxLines: 10, padding: 12)) {
        self.scene = scene
        
        uiNode.zPosition = 1
        scene.addChild(uiNode)
        
        self.textNode = textNode
        textNode.position = CGPoint(x: 20, y: 20)
        uiNode.addChild(textNode)
    }
    
    func setText(_ text: String, completion: @escaping () -> Void) {
        if textNode.isAnimating {
            textNode.skipAnimation()
        }
        textNode.addTextWithAnimation(text, completion: completion)
    }
    
    func clearText() {
        textNode.clearText()
    }
}
