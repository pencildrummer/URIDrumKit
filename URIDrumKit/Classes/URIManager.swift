//
//  URIManager.swift
//  Pods
//
//  Created by Fabio Borella on 20/02/17.
//
//

import Foundation

public typealias URIHandlerBlock = (params: [String: AnyObject]?)->()

public class URIManager {
    
    public static var scheme: String?
    
    private var handlers: [URIHandler] = []
    
    public class func addHandler(path: String, block: URIHandlerBlock) {
        let handler = URIHandler(path: path, block: block)
        sharedManager.handlers.append(handler)
    }
    
    public class func shouldHandleURL(url: NSURL) -> Bool {
        guard let scheme = self.scheme else {
            return false
        }
        
        guard let urlScheme = url.scheme where urlScheme == scheme else {
            return false
        }
        
        return true
    }

    private static let sharedManager: URIManager = URIManager()
    
    public class func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        var didHandleURL = false
        
        for handler in sharedManager.handlers {
            if handler.matchURL(url) {
                let params = handler.parametersURL(url)
                handler.block(params: params)
                
                didHandleURL = true
            }
        }
        
        return didHandleURL
    }
    
}
