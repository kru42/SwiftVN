//
//  VNScene.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SpriteKit

class VNScene: SKScene {
    var backgroundNode: SKSpriteNode?
    var imageNodes: [SKSpriteNode] = []
    
    var backgroundArchive: ArchiveManager?
    var foregroundArchive: ArchiveManager?
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
    }

    func loadBackgroundImage(named name: String) {
        let texture = SKTexture(imageNamed: name)
        
        backgroundNode = SKSpriteNode(texture: texture)
        backgroundNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode?.size = size
        addChild(backgroundNode!)
    }
    
    func addImage(named name: String, position: CGPoint) {
        guard let texture = loadTexture(from: name) else { return }
        
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.position = position
        imageNodes.append(spriteNode)
        addChild(spriteNode)
    }
    
    func loadTexture(from fileName: String, isBackground: Bool = false) -> SKTexture? {
        let filePath = "\(isBackground ? "background" : "foreground")/\(fileName)"
        
        var image: UIImage?
        if isBackground {
            image = backgroundArchive?.extractImage(named: filePath)
        } else {
            image = foregroundArchive?.extractImage(named: filePath)
        }
        
        return SKTexture(image: image!)
    }
    
    func clearImages() {
        for node in imageNodes {
            node.removeFromParent()
        }
        
        imageNodes.removeAll()
    }
}
