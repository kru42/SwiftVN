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
    
    private var textNode: TextNode?
    
    var backgroundArchive: ArchiveManager?
    var foregroundArchive: ArchiveManager?
    
    private let contentNode = SKNode()
    private let uiNode = SKNode()
    
    override func didMove(to view: SKView) {
        backgroundColor = .gray
        
        addChild(contentNode)
        addChild(uiNode)
        
        textNode = TextNode(fontSize: 16, maxLines: 10, padding: 10)
        if let textNode = textNode {
            print(String(describing: textNode))
            uiNode.addChild(textNode)
        }
        
        NotificationCenter.default.post(name: .sceneReady, object: nil)
    }
    
    // Doesn't actually always render one single line, but a character script line which can include multiple
    func renderTextLineWithAnimation(_ line: String) {
        print(String(describing: textNode))
        textNode?.addLineWithAnimation(line)
    }

    // Load background image
    func loadBackground(path: String, withAnimationFrames frames: Double?) {
        loadBackgroundImage(named: path)
    }
    
    // Set foreground image
    func setForegroundImage(fileName: String, x: CGFloat, y: CGFloat) {
        addImage(named: fileName, position: CGPoint(x: x, y: y))
    }

    private func loadBackgroundImage(named name: String) {
        guard let texture = loadTexture(from: name, isBackground: true) else { return }
        
        backgroundNode = SKSpriteNode(texture: texture)
        backgroundNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode?.size = size
        contentNode.addChild(backgroundNode!)
    }
    
    private func addImage(named name: String, position: CGPoint) {
        guard let texture = loadTexture(from: name) else { return }
        
        let spriteNode = SKSpriteNode(texture: texture)
        spriteNode.position = position
        imageNodes.append(spriteNode)
        contentNode.addChild(spriteNode)
    }
    
    func loadTexture(from fileName: String, isBackground: Bool = false) -> SKTexture? {
        let filePath = "\(isBackground ? "background" : "foreground")/\(fileName)"
        
        var archive: ArchiveManager?
        if isBackground {
            archive = backgroundArchive
        } else {
            archive = foregroundArchive
        }
        
        let image = archive?.extractImage(named: filePath)
        
        return SKTexture(image: image!)
    }
    
    func clearImages() {
        for node in imageNodes {
            node.removeFromParent()
        }
        
        imageNodes.removeAll()
    }
}
