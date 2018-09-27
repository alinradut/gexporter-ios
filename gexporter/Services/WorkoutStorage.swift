//
//  Storage.swift
//  gexporter
//
//  Created by clawoo on 19/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import Foundation

enum FileType: String {
    case gpx = "GPX"
    case fit = "FIT"
}

struct File {
    let url: URL
    let type: FileType
    
    var filename: String {
        return url.lastPathComponent
    }
    
    var name: String {
        return (url.lastPathComponent as NSString).deletingPathExtension
    }
    
    var shortName: String {
        return String((name as NSString).deletingPathExtension.prefix(15))
    }
}

protocol FileStorage {
    var onShouldRefresh: (() -> Void)? { get set }
    var fitFiles: [File] { get }
    var gpxFiles: [File] { get }
    
    func refresh()
    func rename(_ file: File, name: String) -> Bool
    func remove(_ file: File) -> Bool
}

class WorkoutStorage: FileStorage {
    
    private var fileManager: FileManager = FileManager.default
    private var root: URL = URL.init(fileURLWithPath: FileManager.documentsDirectory())

    private var files: [File] = [] {
        didSet {
           gpxFiles = files.filter({ $0.type == .gpx })
           fitFiles = files.filter({ $0.type == .fit })
        }
    }
    
    private(set) var fitFiles: [File] = []
    private(set) var gpxFiles: [File] = []
    
    var onShouldRefresh: (() -> Void)?
    
    func refresh() {
        files = fileManager.enumerator(at: root, includingPropertiesForKeys: nil)?.compactMap({ item -> File? in
            guard let url = item as? URL else {
                return nil
            }
            
            switch FileType(rawValue: url.pathExtension.uppercased()) {
            case .gpx?:
                return File(url: url, type: .gpx)
            case .fit?:
                return File(url: url, type: .fit)
            default:
                return nil
            }
        }) ?? []
    }
    
    func rename(_ file: File, name: String) -> Bool {
        var fileName = name
        let pathExtension = "." + (file.url.lastPathComponent as NSString).pathExtension
        var counter = 0
        while fileManager.fileExists(atPath: root.appendingPathComponent(fileName + pathExtension).path) {
            counter += 1
            fileName = (file.url.lastPathComponent as NSString).deletingLastPathComponent + " (\(counter))"
        }
        
        do {
            try fileManager.moveItem(at: file.url, to: file.url.deletingLastPathComponent().appendingPathComponent(fileName + pathExtension))
            return true
        }
        catch {
            return false
        }
    }
    
    func remove(_ file: File) -> Bool {
        do {
            try fileManager.removeItem(at: file.url)
            return true
        }
        catch {
            return false
        }
    }
}
