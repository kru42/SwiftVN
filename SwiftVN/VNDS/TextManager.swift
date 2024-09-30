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
        
        textNode = TextNode(fontSize: 16, maxLines: 10, padding: 12)
        textNode.position = CGPoint(x: 20, y: 20)
        uiNode.addChild(textNode)
    }
    
    func setText(_ text: String, completion: @escaping () -> Void) {
        if textNode.isAnimating {
            textNode.skipAnimation()
        }
        textNode.addTextWithAnimation(text, completion: completion)
    }
}
