//
//  WebServer.swift
//  gexporter
//
//  Created by clawoo on 19/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import Foundation
import GCDWebServer

class WebServer {
    private var webServer: GCDWebServer = GCDWebServer()
    private var storage: FileStorage
    
    private let port = UInt(22222)
    private lazy var baseURL = URL(string: "http://localhost:\(port)")!
    
    private lazy var responseFactory = ResponseFactory(baseURL: baseURL)
    
    init(storage: FileStorage = WorkoutStorage()) {
        self.storage = storage
    }
    
    func start() {
        guard !webServer.isRunning else {
            return
        }
        
        webServer.addHandler(forMethod: "GET", path: "/dir.json", request: GCDWebServerRequest.self) { [weak self] (request) -> GCDWebServerResponse? in
            return self?.handleListing(request)
        }
        
        webServer.addHandler(match: { (method, url, headers, path, query) -> GCDWebServerRequest? in
            
            guard path != "/dir.json",
                method == "GET",
                query["type"] as? String == "GPX"
                else {
                return nil
            }
            return GCDWebServerRequest(method: method, url: url, headers: headers, path: path, query: query)
            
        }) { [weak self] (request) -> GCDWebServerResponse? in
            return self?.handleDownload(request, type: .gpx)
        }
        
        webServer.addHandler(match: { (method, url, headers, path, query) -> GCDWebServerRequest? in
            
            guard path != "/dir.json",
                method == "GET",
                query["type"] as? String == "FIT"
                else {
                    return nil
            }
            return GCDWebServerRequest(method: method, url: url, headers: headers, path: path, query: query)
            
        }) { [weak self] (request) -> GCDWebServerResponse? in
            return self?.handleDownload(request, type: .fit)
        }

        webServer.start(withPort: port, bonjourName: nil)
    }
    
    func stop() {
        guard webServer.isRunning else {
            return
        }
        webServer.stop()
    }
    
    private func handleListing(_ request: GCDWebServerRequest) -> GCDWebServerResponse? {
        guard let rawType = request.query?["type"] as? String,
            let type = FileType(rawValue: rawType) else {
                return responseFactory.badRequest()
        }
        let shortFilenames = request.query?["short"] as? String == "1"
        
        var files: [File] = []
        
        switch type {
        case .gpx:
            files = storage.gpxFiles
        case .fit:
            files = storage.fitFiles
        }
        
        guard !files.isEmpty else {
            return responseFactory.notFound()
        }
        
        return responseFactory.listing(files: files, shortFilenames: shortFilenames)
    }
    
    private func handleDownload(_ request: GCDWebServerRequest, type: FileType) -> GCDWebServerResponse? {
        let name = request.url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        switch type {
        case .gpx:
            guard let file = storage.gpxFiles.filter({ $0.shortName == name }).first else {
                return responseFactory.notFound()
            }
            
            return responseFactory.gpx(file)
        case .fit:
            guard let file = storage.fitFiles.filter({ $0.shortName == name }).first else {
                return responseFactory.notFound()
            }
            
            return responseFactory.fit(file)
        }
    }
    
    struct ResponseFactory {
        
        var baseURL: URL
        
        func listing(files: [File], shortFilenames: Bool) -> GCDWebServerDataResponse? {
            
            let tracks = files.map { (file) -> [String : String] in
                return [
                    "url" : shortFilenames ? file.shortName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)! : baseURL.appendingPathComponent(file.filename.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!).absoluteString,
                    "title" : file.name
                ]
            }
            
            let dictionary = ["tracks" : tracks]
            
            let response = GCDWebServerDataResponse(jsonObject: dictionary)
            return response
        }
        
        func gpx(_ file: File) -> GCDWebServerResponse? {
            
            let response = GCDWebServerFileResponse(file: file.url.path)
            response?.contentType = "application/gpx+xml"
            return response
        }
        
        func fit(_ file: File) -> GCDWebServerResponse? {
            let response = GCDWebServerFileResponse(file: file.url.path)
            response?.contentType = "application/fit"
            return response
        }
        
        func notFound() -> GCDWebServerResponse? {
            let dictionary = ["error": "Not found"]
            let response = GCDWebServerDataResponse(jsonObject: dictionary)
            response?.statusCode = 404
            return response
        }
        
        func badRequest() -> GCDWebServerResponse? {
            
            let dictionary = ["error": "Bad request"]
            let response = GCDWebServerDataResponse(jsonObject: dictionary)
            response?.statusCode = 400
            return response
        }
    }
}
