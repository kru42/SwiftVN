//
//  ArchiveManager.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import Foundation
import ZIPFoundation
import Dispatch

class ArchiveManager {
    private var archive: Archive?
    private let logger = LoggerFactory.shared
    private let queue = DispatchQueue(label: "com.archivemanager.queue", attributes: .concurrent)
    
    init(zipFileName: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            guard let zipFileURL = self.getZipFileURL(for: zipFileName) else {
                self.logger.error("Error: ZIP file not found.")
                return
            }
            
            do {
                self.archive = try Archive(url: zipFileURL, accessMode: .read, pathEncoding: .utf8)
            } catch {
                self.logger.error("Error loading ZIP file: \(error.localizedDescription)")
            }
        }
    }
    
    private func getZipFileURL(for zipFileName: String) -> URL? {
        return SwiftVN.baseDirectory.appendingPathComponent(zipFileName)
    }
    
    func extractFile(named fileName: String, completion: @escaping (Data?) -> Void) {
        queue.sync { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            guard let archive = self.archive else {
                self.logger.error("No archive loaded.")
                completion(nil)
                return
            }
            
            var fileData = Data()
            let lowercasedFileName = fileName.lowercased()
            
            if let matchingFileName = archive.first(where: { $0.path.lowercased() == lowercasedFileName })?.path {
                do {
                    guard let entry = archive[matchingFileName] else {
                        self.logger.error("Unable to find file \(fileName) in archive")
                        completion(nil)
                        return
                    }
                    
                    _ = try archive.extract(entry) { data in
                        fileData.append(data)
                    }
                    completion(fileData)
                } catch {
                    self.logger.error("Error extracting file: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                self.logger.error("File not found: \(fileName)")
                completion(nil)
            }
        }
    }
    
    func extractImage(named fileName: String, completion: @escaping (UIImage?) -> Void) {
        extractFile(named: fileName) { data in
            guard let data = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: data))
        }
    }
}
