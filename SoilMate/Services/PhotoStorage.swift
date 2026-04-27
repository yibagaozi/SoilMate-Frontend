//
//  PhotoStorage.swift
//  SoilMate
//
//  Created by yibagaozi on 2026/4/20.
//

import Foundation
import UIKit

enum PhotoStorage {

    // MARK: - Folder

    private static var folderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = docs.appendingPathComponent("plant_photos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    // MARK: - Save / Load / Delete

    /// Save image as JPEG, return relative filename (e.g. "ABC-123.jpg").
    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = folderURL.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("[PhotoStorage] Save failed: \(error)")
            return nil
        }
    }

    /// Load UIImage from local filename. Returns nil if file is missing.
    static func load(_ filename: String) -> UIImage? {
        let url = folderURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// Delete a photo file. Safe to call even if file doesn't exist.
    static func delete(_ filename: String) {
        let url = folderURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Helpers

    /// True if the value looks like a local filename (not a remote URL).
    static func isLocal(_ photoUrl: String?) -> Bool {
        guard let s = photoUrl, !s.isEmpty else { return false }
        return !s.hasPrefix("http")
    }
}
