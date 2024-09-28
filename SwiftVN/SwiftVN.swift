//
//  SwiftVN.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Foundation

// Notification definitions
extension Notification.Name {
    static let loadEvent = Notification.Name("loadEvent")
    static let assetsLoaded = Notification.Name("assetsLoaded")
}

class SwiftVN {
    // TODO: currently, we have one single novel placed there. We eventually need a menu with all novels and selection
    // Initialize baseDirectory to the default "novels/"
    static let baseDirectory: URL = {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            return url.appendingPathComponent("novels")
        } catch {
            fatalError("Error initializing baseDirectory: \(error.localizedDescription)")
        }
    }()
    
    init() {
        let fileManager = FileManager.default
        
        // Create the "novels" directory if it doesn't exist yet (first run)
        do {
            let documentsDir = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            if !fileManager.fileExists(atPath: documentsDir.appendingPathComponent("novels").path) {
                try fileManager.createDirectory(at: documentsDir.appendingPathComponent("novels"), withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func prepareAssets() {
        NotificationCenter.default.addObserver(ImageViewModel.shared, selector: #selector(ImageViewModel.handleLoadEvent), name: .loadEvent, object: nil)
        NotificationCenter.default.addObserver(ImageViewModel.shared, selector: #selector(handleAssetsLoaded), name: .assetsLoaded, object: nil)
        NotificationCenter.default.post(name: .loadEvent, object: nil)
    }
}
