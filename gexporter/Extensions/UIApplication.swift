//
//  UIApplication.swift
//  gexporter
//
//  Created by clawoo on 19/09/2018.
//  Copyright © 2018 clawoo. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// Returns the first registered URL scheme
    ///
    /// - Returns: URL scheme
    static func registeredUrlScheme() -> String {
        let urlTypes = (Bundle.main.infoDictionary!["CFBundleURLTypes"] as! [[String : Any]]).first!
        return (urlTypes["CFBundleURLSchemes"] as! [String]).first!
    }
}
