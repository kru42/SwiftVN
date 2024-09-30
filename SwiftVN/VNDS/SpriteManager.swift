//
//  SpriteManager.swift
//  SwiftVN
//
//  Created by Kru on 30/09/24.
//

import SpriteKit

class SpriteManager {
    private var foregroundArchive = ArchiveManager(zipFileName: "foreground.zip")
    private var backgroundArchive = ArchiveManager(zipFileName: "background.zip")

    var backgroundNode: SKSpriteNode?
    var imageNodes: [SKSpriteNode] = []
    
    private let scene: SKScene
    
    private var textNode: TextNode!
    private let contentNode = SKNode()
    private let uiNode = SKNode()
    
    private let logger = LoggerFactory.shared
    
    init(scene: SKScene) {
        self.scene = scene
        
        contentNode.zPosition = -1
        scene.addChild(contentNode)
    }
    
    func setBackground(path: String, withAnimationFrames frames: Double?) {
        guard let texture = loadTexture(from: path, isBackground: true) else { return }

        let backgroundNode = SKSpriteNode(texture: texture)
        
        // Calculate the size that fits within the screen while maintaining the original aspect ratio
        let imageAspectRatio = texture.size().width / texture.size().height
        let screenAspectRatio = scene.size.width / scene.size.height
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        // Fit the image within the screen bounds, scaling up if necessary but maintaining aspect ratio
        if imageAspectRatio > screenAspectRatio {
            // Image is wider relative to the screen, fit to width
            newWidth = scene.size.width
            newHeight = newWidth / imageAspectRatio
        } else {
            // Image is taller relative to the screen, fit to height
            newHeight = scene.size.height
            newWidth = newHeight * imageAspectRatio
        }
        
        // Stretch the image if smaller, up to the screen bounds
        if newWidth < scene.size.width {
            newWidth = scene.size.width
            newHeight = newWidth / imageAspectRatio
        }
        
        if newHeight < scene.size.height {
            newHeight = scene.size.height
            newWidth = newHeight * imageAspectRatio
        }
        
        backgroundNode.size = CGSize(width: newWidth, height: newHeight)
        
        // Center the background
        backgroundNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        
        // Set the anchor point to the center
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Remove any existing background node
        self.backgroundNode?.removeFromParent()
        
        // Set the new background node
        self.backgroundNode = backgroundNode
        contentNode.addChild(backgroundNode)
    }
    
    // Set foreground image
    func setForeground(fileName: String, x: CGFloat, y: CGFloat) {
        addImage(named: fileName, position: CGPoint(x: x, y: y))
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
        
        let archive: ArchiveManager
        if isBackground {
            archive = backgroundArchive
        } else {
            archive = foregroundArchive
        }
        
        guard let image = archive.extractImage(named: filePath) else { return nil }
        return SKTexture(image: image)
    }
    
    func clearImages() {
        for node in imageNodes {
            node.removeFromParent()
        }
        
        imageNodes.removeAll()
    }
}
