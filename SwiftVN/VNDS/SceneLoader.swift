//
//  ImageViewModel.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import SwiftUI
import Combine
import SpriteKit

// ViewModel to manage state and actions
class SpriteManager: Loadable, ObservableObject {
    // Singleton instance
    static var hasLoaded = false {
        didSet {
            // Notify all observers when the assets have loaded
            NotificationCenter.default.post(name: .assetsLoaded, object: nil)
        }
    }
    
    @Published var isLoading: Bool = true
    
    // Foreground and background images archives
    private static var foregroundArchive: ArchiveManager?
    private static var backgroundArchive: ArchiveManager?
    
    var scene: VNScene?
    private let logger = LoggerFactory.shared
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(SpriteManager.handleLoadEvent), name: .loadEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SpriteManager.handleAssetsLoaded), name: .assetsLoaded, object: nil)
    }
    
    func setupScene(in view: SKView) {
        let scene = VNScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundArchive = SpriteManager.backgroundArchive
        scene.foregroundArchive = SpriteManager.foregroundArchive
        view.presentScene(scene)
        self.scene = scene
    }
    
    func getScene() -> VNScene {
        return scene!
    }
    
    @objc func handleLoadEvent() {
        tryLoad()
    }
    
    @objc func handleAssetsLoaded() {
        isLoading = false
    }

    func loadHandler() {
        logger.info("Opening images ZIP...")
        SpriteManager.foregroundArchive = ArchiveManager(zipFileName: "foreground.zip")
        SpriteManager.backgroundArchive = ArchiveManager(zipFileName: "background.zip")
    }

    // Load background image
    func loadBackground(path: String, withAnimationFrames frames: Double?) {
        scene?.loadBackgroundImage(named: path)
    }
    
    // Set foreground image
    func setForegroundImage(fileName: String, x: CGFloat, y: CGFloat) {
        scene?.addImage(named: fileName, position: CGPoint(x: x, y: y))
    }
    
    func clearImages() {
        scene?.clearImages()
    }
}

