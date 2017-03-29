//
//  URIManager.swift
//  Pods
//
//  Created by Fabio Borella on 20/02/17.
//
//

import Foundation

public typealias URIHandlerBlock = (_ params: [String: String]?)->()

open class URIManager {
    
    open static var scheme: String?
    
    fileprivate var handlers: [URIHandler] = []
    
    open class func addHandler(_ path: String, block: @escaping URIHandlerBlock) {
        let handler = URIHandler(path: path, block: block)
        sharedManager.handlers.append(handler)
    }
    
    open class func shouldHandleURL(_ url: URL) -> Bool {
        guard let scheme = self.scheme else {
            return false
        }
        
        guard let urlScheme = url.scheme, urlScheme == scheme else {
            return false
        }
        
        return true
    }

    fileprivate static let sharedManager: URIManager = URIManager()
    
    open class func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        var didHandleURL = false
        
        for handler in sharedManager.handlers {
            if handler.matchURL(url) {
                let params = handler.parametersURL(url)
                handler.block(params)
                
                didHandleURL = true
            }
        }
        
        return didHandleURL
    }
    
}
