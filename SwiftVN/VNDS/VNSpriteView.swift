//
//  VNSpriteView.swift
//  SwiftVN
//
//  Created by Kru on 29/09/24.
//

import SwiftUI
import SpriteKit

struct CustomSpriteView: UIViewRepresentable {
    var spriteManager: SpriteManager
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        // Set up the scene in SKView
        spriteManager.setupScene(in: skView) // Pass the SKView to setupScene
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Update logic can be added here if needed
    }
}
