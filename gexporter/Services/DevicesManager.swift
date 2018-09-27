//
//  DevicesManager.swift
//  gexporter
//
//  Created by clawoo on 19/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import UIKit
import Foundation
import ConnectIQ

class DevicesManager {
    
    var connectIq: ConnectIQ
    private var store: DevicesStore = UserDefaultsStore()
    
    var devices: [IQDevice] = []
    var onDevicesChanged: (() -> Void)?
    
    init(connectIq: ConnectIQ = .sharedInstance()) {
        self.connectIq = connectIq
        devices = store.devices()
    }
    
    func refreshDevices() {
        connectIq.showDeviceSelection()
    }
    
    func importDevicesFromUrl(_ url: URL) {
        devices = connectIq.parseDeviceSelectionResponse(from: url)?.compactMap({ $0 as? IQDevice }) ?? []
        store.store(devices: devices)
        onDevicesChanged?()
    }
}
