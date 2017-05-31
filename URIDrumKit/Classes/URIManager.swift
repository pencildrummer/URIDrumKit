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
        URIManager.default.handlers.append(handler)
    }

    fileprivate static let `default`: URIManager = URIManager()
    
    // MARK: URL handling
    
    open class func shouldHandleURL(_ url: URL) -> Bool {
        guard let scheme = self.scheme else {
            return false
        }
        
        guard let urlScheme = url.scheme, urlScheme == scheme else {
            return false
        }
        
        return true
    }
    
    open class func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return URIManager.default.handleUrl(url: url, checkScheme: true)
    }
    
    // MARK: Universal link handling
    
    open class func shouldHandleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            return true
        }
        return false
    }
    
    open class func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            return URIManager.default.handleUrl(url: url, checkScheme: false)
        }
        return false
    }
    
    public class func handleUrl(url: URL, checkScheme: Bool) -> Bool {
        return URIManager.default.handleUrl(url: url, checkScheme: checkScheme)
    }
    
    // MARK: Internal helpers
    
    fileprivate func handleUrl(url: URL, checkScheme: Bool) -> Bool {
        var didHandleURL = false
        
        for handler in URIManager.default.handlers {
            if handler.matchURL(url, checkScheme: checkScheme) {
                let params = handler.parametersURL(url, checkScheme: checkScheme)
                handler.block(params)
                
                didHandleURL = true
            }
        }
        
        return didHandleURL
    }
    
}
