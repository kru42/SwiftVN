//
//  ArchiveManager.swift
//  SwiftVN
//
//  Created by Kru on 28/09/24.
//

import ZIPFoundation

class ArchiveManager {
    var archive: Archive?
    
    init(zipFileName: String) {
        // Load ZIP file into the archive
        guard let zipFileURL = getZipFileURL(for: zipFileName) else {
            print("Error: ZIP file not found.")
            return
        }
        print(zipFileURL.path)
        
        do {
            archive = try Archive.init(url: zipFileURL, accessMode: .read, pathEncoding: String.Encoding.utf8)
        } catch {
            print("Error loading ZIP file: \(error.localizedDescription)")
            return
        }
    }
    
    func getZipFileURL(for zipFileName: String) -> URL? {
        return SwiftVN.baseDirectory.appendingPathComponent("\(zipFileName)")
    }
    
    func extractFile(named fileName: String) -> Data? {
        guard let archive = archive else {
            print("No archive loaded.")
            return nil
        }
        
        // TODO: handle entry not found
        
        var fileData = Data()
        
        do {
            _ = try archive.extract(archive[fileName]!) { data in
                fileData.append(data)
            }
            return fileData
        } catch {
            print("Error extracting file: \(error.localizedDescription)")
            return nil
        }
    }
}
