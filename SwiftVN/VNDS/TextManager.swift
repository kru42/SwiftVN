//
//  TextManager.swift
//  SwiftVN
//
//  Created by Kru on 30/09/24.
//

import SpriteKit

class TextManager {
    private let scene: SKScene
    
    private var textNode: TextNode
    private let uiNode = SKNode()
    
    init(scene: SKScene, textNode: TextNode = TextNode(fontSize: 16, maxLines: 10, padding: 12)) {
        self.scene = scene
        
        uiNode.zPosition = 1
        scene.addChild(uiNode)
        
        self.textNode = textNode
        textNode.position = CGPoint(x: 20, y: 20)
        uiNode.addChild(textNode)
    }
    
    func setText(_ text: String, animated: Bool = true, completion: (() -> Void)? = nil) {
        if animated {
            if textNode.isAnimating {
                textNode.skipAnimation()
            }
            
            textNode.addTextWithAnimation(text) {
                completion?()
            }
        } else {
            textNode.setCurrentLine(text)
            completion?()
        }
    }
    
    func clearText() {
        textNode.clearText()
    }
    
    func skipAnimation() {
        textNode.skipAnimation()
    }
    
    func getFontName() -> String {
        return textNode.textFont.fontName
    }
}
