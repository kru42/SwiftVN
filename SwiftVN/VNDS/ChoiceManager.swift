//
//  ChoiceManager.swift
//  SwiftVN
//
//  Created by Kru on 01/10/24.
//

import SpriteKit

class ChoiceManager {
    private let scene: SKScene
    private var choiceNodes: [SKNode] = []
    private var onSelection: ((Int) -> Void)?
    
    private let logger = LoggerFactory.shared
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func presentChoices(_ options: [String], onSelection: @escaping (Int) -> Void) {
        self.onSelection = onSelection
        
        let choiceContainer = SKNode()
        choiceContainer.name = "choiceContainer"
        
        for (index, option) in options.enumerated() {
            let button = SKSpriteNode(color: .black.withAlphaComponent(0.8), size: CGSize(width: 200, height: 50))
            button.position = CGPoint(x: 0, y: -CGFloat(index * 60))
            button.name = "choice_\(index)"
            
            let label = SKLabelNode(text: option)
            label.fontColor = .white
            label.fontName = "HelveticaNeue-Light"
            label.verticalAlignmentMode = .center
            button.addChild(label)
            
            choiceContainer.addChild(button)
            choiceNodes.append(button)
        }
        
        choiceContainer.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 100)
        scene.addChild(choiceContainer)
    }
    
    func handleTap(at position: CGPoint) -> Bool {
        guard let choiceContainer = scene.childNode(withName: "choiceContainer") else { return false }
        
        // Convert the tap position to the choiceContainer's coordinate space
        let localPosition = choiceContainer.convert(position, from: scene)
        
        for (index, choiceNode) in choiceNodes.enumerated() {
            if choiceNode.frame.contains(localPosition) {
                onSelection?(index + 1)
                clearChoices()
                return true
            }
        }
        return false
    }
    
    func clearChoices() {
        scene.childNode(withName: "choiceContainer")?.removeFromParent()
        choiceNodes.removeAll()
    }
    
    var hasActiveChoices: Bool {
        return !choiceNodes.isEmpty
    }
}
