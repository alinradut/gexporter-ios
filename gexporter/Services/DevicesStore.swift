//
//  DevicesStore.swift
//  gexporter
//
//  Created by clawoo on 20/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import Foundation
import ConnectIQ

protocol DevicesStore {
    func store(devices: [IQDevice])
    func devices() -> [IQDevice]
}

class UserDefaultsStore: DevicesStore
{
    enum Keys: String {
        case devices = "devices"
    }
    
    func store(devices: [IQDevice]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: devices)
        UserDefaults.standard.set(data, forKey: Keys.devices.rawValue)
    }
    
    func devices() -> [IQDevice] {
        if let data = UserDefaults.standard.data(forKey: Keys.devices.rawValue) {
            if let devices = NSKeyedUnarchiver.unarchiveObject(with: data) as? [IQDevice] {
                return devices
            }
        }
        return []
    }
}
