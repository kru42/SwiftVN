//
//  HistoryOverlayNode.swift
//  SwiftVN
//
//  Created by Kru on 30/09/24.
//

import SpriteKit

class HistoryOverlayNode: SKNode {
    private let background: SKShapeNode
    private let scrollNode: SKNode
    private let cropNode: SKCropNode
    private let maskNode: SKSpriteNode
    private var historyLines: [String] = []
    private let lineHeight: CGFloat = 30
    private let padding: CGFloat = 20
    private let fontSize: CGFloat = 16
    
    init(size: CGSize) {
        // Create semi-transparent background
        background = SKShapeNode(rectOf: size)
        background.fillColor = UIColor(white: 0, alpha: 0.7)
        background.strokeColor = .clear
        
        // Create scroll node to contain history lines
        scrollNode = SKNode()
        
        // Create crop node for scrolling effect
        cropNode = SKCropNode()
        
        // Create mask node for scrolling effect
        maskNode = SKSpriteNode(color: .white, size: CGSize(width: size.width - padding * 2, height: size.height - padding * 2))
        
        super.init()
        
        isUserInteractionEnabled = true
        
        addChild(background)
        addChild(cropNode)
        
        cropNode.addChild(scrollNode)
        cropNode.maskNode = maskNode
        
        cropNode.position = CGPoint(x: padding, y: padding)
        maskNode.position = CGPoint(x: (size.width - padding * 2) / 2, y: (size.height - padding * 2) / 2)
        
        scrollNode.position = CGPoint(x: 0, y: size.height - padding * 2)
        
        self.zPosition = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addHistoryLine(_ line: String) {
        historyLines.append(line)
        updateHistoryDisplay()
    }
    
    private func updateHistoryDisplay() {
        scrollNode.removeAllChildren()
        
        for (index, line) in historyLines.enumerated().reversed() {
            let label = SKLabelNode(fontNamed: "ArialMT")
            label.text = line
            label.fontSize = fontSize
            label.fontColor = .white
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .top
            label.position = CGPoint(x: 0, y: -CGFloat(index) * lineHeight)
            
            scrollNode.addChild(label)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        let deltaY = location.y - previousLocation.y
        scrollNode.position.y += deltaY
        
        // Constrain scrolling
        let minY = cropNode.frame.minY
        let maxY = cropNode.frame.maxY + CGFloat(historyLines.count) * lineHeight - cropNode.frame.height
        scrollNode.position.y = min(max(scrollNode.position.y, minY), maxY)
    }
}
