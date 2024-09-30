//
//  ArchiveManager.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import ZIPFoundation

class ArchiveManager {
    var archive: Archive?
    let logger = LoggerFactory.shared
    
    init(zipFileName: String) {
        // Load ZIP file into the archive
        guard let zipFileURL = getZipFileURL(for: zipFileName) else {
            print("Error: ZIP file not found.")
            return
        }
        
        do {
            archive = try Archive.init(url: zipFileURL, accessMode: .read, pathEncoding: String.Encoding.utf8)
        } catch {
            print("Error loading ZIP file: \(error.localizedDescription)")
            return
        }
    }
    
    func getFileNames() -> [String] {
        guard let archive = archive else { return [] }
        return archive.map { $0.path }
    }
    
    func getZipFileURL(for zipFileName: String) -> URL? {
        return SwiftVN.baseDirectory.appendingPathComponent("\(zipFileName)")
    }
    
    func extractFile(named fileName: String) -> Data? {
        guard let archive = archive else {
            print("No archive loaded.")
            return nil
        }
        
        var fileData = Data()
        
        // Find the file case insensitively
        // FIXME: It's bugged
        if let matchingFileName = getFileNames().first(where: { $0.lowercased() == fileName.lowercased() }) {
            do {
                guard let entry = archive[matchingFileName] else {
                    logger.error("Unable to find file \(fileName) in archive")
                    return nil
                }
                
                _ = try archive.extract(entry) { data in
                    fileData.append(data)
                }
                return fileData
            } catch {
                print("Error extracting file: \(error.localizedDescription)")
                return nil
            }
        } else {
            print("File not found: \(fileName)")
            return nil
        }
//    }
    
    func extractImage(named fileName: String) -> UIImage? {
        guard let data = extractFile(named: fileName) else {
            return nil
        }
        
        return UIImage(data: data)
    }
}
