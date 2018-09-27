//
//  ServiceManager.swift
//  gexporter
//
//  Created by clawoo on 19/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import UIKit
import ConnectIQ

class ServiceManager {
    
    static var shared: ServiceManager = ServiceManager()
    
    var storage: FileStorage = WorkoutStorage()
    
    lazy var webServer: WebServer = WebServer(storage: storage)
    
    lazy var devicesManager: DevicesManager = {
        
        let connectIq = ConnectIQ.sharedInstance()!
        connectIq.initialize(withUrlScheme: UIApplication.registeredUrlScheme(), uiOverrideDelegate: nil)
        
        let manager = DevicesManager(connectIq: connectIq)
        return manager
    }()
}

