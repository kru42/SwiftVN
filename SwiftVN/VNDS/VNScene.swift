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
            uiNode.addChild(textNode)
        }
        
        NotificationCenter.default.post(name: .sceneReady, object: nil)
    }
    
    func setTextWithAnimation(_ line: String) {
        // TODO: if the text is currently rendering, just render it all instantly instead of adding new text
        //  and return something
        textNode?.setTextWithAnimation(line)
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
        
        // Get screen size
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Original image dimensions
        let originalWidth = texture.size().width
        let originalHeight = texture.size().height
        
        // Calculate size scale for the image
        let sx = screenWidth / originalWidth
        let sy = screenHeight / originalHeight
        let scale = min(sx, sy) // Keep aspect ratio
        
        // Calculate position scaling
        let px = screenWidth / originalWidth
        let py = screenHeight / originalHeight
        let pscale = min(px, py)
        
        // Calculate an offset so that the bottom-left corner is at the specified position
        let offsetX = screenWidth / 2 - (originalWidth * scale) / 2
        let offsetY = screenHeight / 2 - (originalHeight * scale) / 2

        let spriteNode = SKSpriteNode(texture: texture)
        
        spriteNode.position = CGPoint(x: position.x * pscale + offsetX, y: position.y * pscale + offsetY)
        spriteNode.setScale(scale)

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
