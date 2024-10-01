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
            let button = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 50))
            button.position = CGPoint(x: 0, y: -CGFloat(index * 60))
            button.name = "choice_\(index)"
            
            let label = SKLabelNode(text: option)
            label.fontColor = .white
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
        
        for (index, choiceNode) in choiceNodes.enumerated() {
            logger.debug("checking for tap at x: \(position.x), y: \(position.y)")
            logger.debug("choice node bounds are x: \(choiceNode.frame.minX) - \(choiceNode.frame.maxX), y: \(choiceNode.frame.minY) - \(choiceNode.frame.maxY)")
            logger.debug("choice container bounds are x: \(choiceContainer.frame.minX) - \(choiceContainer.frame.maxX), y: \(choiceContainer.frame.minY) - \(choiceContainer.frame.maxY)")
            if choiceNode.contains(scene.convert(position, to: choiceNode)) {
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
