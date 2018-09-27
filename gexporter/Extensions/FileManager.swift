//
//  FileManager.swift
//  gexporter
//
//  Created by clawoo on 19/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import Foundation

extension FileManager {
    static func documentsDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
}
