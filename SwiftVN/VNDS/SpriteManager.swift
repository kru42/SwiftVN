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
        // Clear images before drawing new background
        clearImages()
        
        backgroundArchive.extractImage(named: "background/\(path)") { image in
            if image == nil {
                fatalError("Could not load background image for \(path)")
            }
            
            let texture = SKTexture(image: image!)
            let backgroundNode = SKSpriteNode(texture: texture)
            
            let scene = self.scene
            
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
            
            backgroundNode.size = CGSize(width: newWidth, height: newHeight)
            
            // Center the background
            backgroundNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
            
            // Set the anchor point to the center
            backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            // Remove any existing background node
            self.backgroundNode?.removeFromParent()
            
            // Set the new background node
            self.backgroundNode = backgroundNode
            self.contentNode.addChild(backgroundNode)
        }
    }
    
    // Set foreground image
    func setForeground(fileName: String, x: CGFloat, y: CGFloat) {
        addImage(named: fileName, position: CGPoint(x: x, y: y))
    }
    
    private func addImage(named name: String, position: CGPoint) {
        foregroundArchive.extractImage(named: "foreground/\(name)") { image in
            guard let image = image else {
                fatalError("Could not load foreground image for \(name)")
            }
            
            let texture = SKTexture(image: image)
            let foregroundImageNode = SKSpriteNode(texture: texture)
            
            let scene = self.scene
            
            // Calculate the original and new sizes
            let imageAspectRatio = texture.size().width / texture.size().height
            let screenAspectRatio = scene.size.width / scene.size.height
            
            var newWidth: CGFloat
            var newHeight: CGFloat
            
            // Fit the image within the screen bounds, scaling up if necessary while maintaining aspect ratio
            if imageAspectRatio > screenAspectRatio {
                // Image is wider relative to the screen, fit to width
                newWidth = scene.size.width
                newHeight = newWidth / imageAspectRatio
            } else {
                // Image is taller relative to the screen, fit to height
                newHeight = scene.size.height
                newWidth = newHeight * imageAspectRatio
            }
            
            // Stretch the image if it's smaller, up to the screen bounds
            if newWidth < scene.size.width {
                newWidth = scene.size.width
                newHeight = newWidth / imageAspectRatio
            }
            
            if newHeight < scene.size.height {
                newHeight = scene.size.height
                newWidth = newHeight * imageAspectRatio
            }
            
            // Calculate the position offset
            let offsetX = (scene.size.width - newWidth) / 2
            let offsetY = (scene.size.height - newHeight) / 2
            
            // Update the node size and position
            foregroundImageNode.size = CGSize(width: newWidth, height: newHeight)
            foregroundImageNode.position = CGPoint(x: scene.size.width / 2 + offsetX, y: scene.size.height / 2 + offsetY)
            
            // Set the anchor point to the center
            foregroundImageNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            // Add the app image node to the contentNode
            self.imageNodes.append(foregroundImageNode)
            self.contentNode.addChild(foregroundImageNode)
        }
    }
    
    func clearImages() {
        for node in imageNodes {
            node.removeFromParent()
        }
        
        imageNodes.removeAll()
    }
}
