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
class SceneLoader: Loadable, ObservableObject {
    // Singleton instance
    static var hasLoaded = false {
        didSet {
            // Notify all observers when the assets have loaded
            NotificationCenter.default.post(name: .assetsLoaded, object: nil)
        }
    }
    
    @Published var isLoading: Bool = true
    
    // Foreground and background images archives
    private var foregroundArchive: ArchiveManager?
    private var backgroundArchive: ArchiveManager?
    
    var scene: VNScene?
    private let logger = LoggerFactory.shared
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLoadEvent), name: .loadEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAssetsLoaded), name: .assetsLoaded, object: nil)
    }
    
    func setupScene(in view: SKView) {
        let scene = VNScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        
        scene.backgroundArchive = backgroundArchive
        scene.foregroundArchive = foregroundArchive
        
        self.scene = scene
    }
    
    func getScene() -> VNScene {
        if let scene = scene {
            return scene
        } else {
            fatalError("Scene not set")
        }
    }
    
    @objc func handleLoadEvent() {
        tryLoad()
    }
    
    @objc func handleAssetsLoaded() {
        isLoading = false
    }

    func loadHandler() {
        logger.info("Opening images ZIP...")
        foregroundArchive = ArchiveManager(zipFileName: "foreground.zip")
        backgroundArchive = ArchiveManager(zipFileName: "background.zip")
        
        let skView = SKView(frame: UIScreen.main.bounds)
        
        logger.info("Initializing scene nodes and fonts...")
        setupScene(in: skView)
    }
    
    func clearImages() {
        scene?.clearImages()
    }
}

