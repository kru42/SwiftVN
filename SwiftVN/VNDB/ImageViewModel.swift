//
//  ImageViewModel.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import SwiftUI
import Combine

// ImageModel to represent each image
struct ImageModel: Identifiable {
    let id = UUID()
    let path: String
    let x: CGFloat
    let y: CGFloat
    let image: Image
}

// ViewModel to manage state and actions
class ImageViewModel: Loadable, ObservableObject {
    // Singleton instance
    static let shared = ImageViewModel()
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
    
    @Published var backgroundImage: Image?
    @Published var images: [ImageModel] = []
    @Published var alpha: Double = 1.0
//    private var originalWidth: CGFloat = 0
//    private var originalHeight: CGFloat = 0
    
    private let logger = LoggerFactory.shared
    
    @objc func handleLoadEvent() {
        tryLoad()
    }
    
    @objc func handleAssetsLoaded() {
        isLoading = false
    }

    func loadHandler() {
        logger.info("Opening images ZIP...")
        ImageViewModel.foregroundArchive = ArchiveManager(zipFileName: "foreground.zip")
        ImageViewModel.backgroundArchive = ArchiveManager(zipFileName: "background.zip")
    }

    // Load background image
    func loadBackground(path: String, withAnimationFrames frames: Double?) {
        if path.hasSuffix("~") {
            return
        }
        
        // Clear images list
        images.removeAll()
        
        // Assuming `loadImageFromPath` is a function to create a SwiftUI Image from a path
        let newImage = loadImageFromArchive(fileName: path, isBackground: true)
        
        self.backgroundImage = newImage
        
//        // Store original dimensions
//        self.originalWidth = uiImage.size.width
//        self.originalHeight = uiImage.size.height
        
        // Animate alpha if frames are provided
        if let frames = frames {
            withAnimation(.easeInOut(duration: frames / 60.0)) {
                self.alpha = 1.0
            }
        }
    }

//    // Save the current state
//    func save() -> [String: Any] {
//        return [
//            "background": backgroundImage,
//            "images": images.map { ["path": $0.path, "x": $0.x, "y": $0.y] }
//        ]
//    }
//
//    // Restore the saved state
//    func restore(state: [String: Any]) {
//        if let bgPath = state["background"] as? String {
//            loadBackground(path: bgPath, withAnimationFrames: nil)
//        }
//        
//        if let savedImages = state["images"] as? [[String: Any]] {
//            self.images = savedImages.compactMap { imageData in
//                guard let path = imageData["path"] as? String,
//                      let x = imageData["x"] as? CGFloat,
//                      let y = imageData["y"] as? CGFloat else { return nil }
//                let newImage = loadImageFromArchive(path: path)
//                return ImageModel(path: path, x: x, y: y, image: newImage)
//            }
//        }
//    }

    // Set foreground image
    func setForegroundImage(fileName: String, x: CGFloat, y: CGFloat) {
        let newImage = loadImageFromArchive(fileName: fileName)
        let imageModel = ImageModel(path: fileName, x: x, y: y, image: newImage)
        self.images.append(imageModel)
    }

    // Helper to load an image from an archive
    private func loadImageFromArchive(fileName: String, isBackground: Bool = false) -> Image {
        var archive: ArchiveManager
        if isBackground {
            archive = ImageViewModel.backgroundArchive!
        } else {
            archive = ImageViewModel.foregroundArchive!
        }
        
        guard let data = archive.extractFile(named: "\(isBackground ? "background" : "foreground")/\(fileName)") else {
            logger.critical("Failed to load image file \(fileName)")
            fatalError()
        }
        
        let uiImage = UIImage(data: data) ?? UIImage()
        return Image(uiImage: uiImage)
    }
}

