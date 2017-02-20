//
//  URIManager.swift
//  Pods
//
//  Created by Fabio Borella on 20/02/17.
//
//

import Foundation

public class URIManager {
    
    typealias URIHandler = (path: String, block: URIHandlerBlock)
    public typealias URIHandlerBlock = (params: [String: AnyObject]?)->()
    
    public static var scheme: String?
    
    public private(set) static var handlers: [String: URIHandlerBlock]?
    
    public class func addHandler(path: String, block: URIHandlerBlock) {
        if handlers == nil {
            handlers = [:]
        }
        handlers![path] = block
    }

    private static let sharedManager: URIManager = URIManager()
    
    public class func shouldHandleURL(url: NSURL) -> Bool {
        guard let scheme = self.scheme else {
            return false
        }
        
        guard let urlScheme = url.scheme where urlScheme == scheme else {
            return false
        }
        
        return true
    }
    
    public class func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if let possibleHandlers = self.sharedManager.possibleHandlers(url) {
            
            for handler in possibleHandlers {
                
                // Check match urls
                
                if self.sharedManager.handlerMatchURL(handler, url: url) {
                    let params = self.sharedManager.handlerParameters(handler, url: url)
                    handler.block(params: params)
                }
                
            }
            
        }
        
        return false
    }
    
    private func possibleHandlers(url: NSURL) -> [URIHandler]? {
        
        guard let scheme = self.dynamicType.scheme else {
            return nil
        }
        
        guard let urlScheme = url.scheme where urlScheme == scheme else {
            return nil
        }
        
        guard let urlPathComponents = url.absoluteString?.stringByReplacingOccurrencesOfString(urlScheme + "://", withString: "").componentsSeparatedByString("/") else {
            return nil
        }
        
        guard let handlers = self.dynamicType.handlers else {
            return nil
        }
        
        var possibleHandlers: [URIHandler] = []
        
        for handler in handlers {
            
            let handlerPath = handler.0
            let handlerBlock = handler.1
            
            // Build url from path
            
            // Check count of pathComponents
            
            let handlerPathComponents = handlerPath.componentsSeparatedByString("/")
            if handlerPathComponents.count == urlPathComponents.count {
                possibleHandlers.append(URIHandler(path: handlerPath, block: handlerBlock))
            }
        }
        
        return possibleHandlers.count > 0 ? possibleHandlers : nil
    }
    
    private func handlerMatchURL(handler: URIHandler, url: NSURL) -> Bool {
        
        guard let scheme = self.dynamicType.scheme else {
            return false
        }
        
        guard let urlScheme = url.scheme where urlScheme == scheme else {
            return false
        }
        
        guard let urlPathComponents = url.absoluteString?.stringByReplacingOccurrencesOfString(urlScheme + "://", withString: "").componentsSeparatedByString("/") else {
            return false
        }
        
        let handlerPathComponents = handler.path.componentsSeparatedByString("/")
        guard handlerPathComponents.count > 0 else {
            return false
        }
        
        for (index, component) in urlPathComponents.enumerate() {
            
            if handlerPathComponents[index].isParameter() {
                return true
            }
            
            if handlerPathComponents[index] != component {
                return false
            }
        }
        
        return true
    }
    
    private func handlerParameters(handler: URIHandler, url: NSURL) -> [String: AnyObject]? {
        
        guard let scheme = self.dynamicType.scheme else {
            return nil
        }
        
        guard let urlScheme = url.scheme where urlScheme == scheme else {
            return nil
        }
        
        guard let urlPathComponents = url.absoluteString?.stringByReplacingOccurrencesOfString(urlScheme + "://", withString: "").componentsSeparatedByString("/") else {
            return nil
        }
        
        let handlerPathComponents = handler.path.componentsSeparatedByString("/")
        guard handlerPathComponents.count > 0 else {
            return nil
        }
        
        var parameters: [String: AnyObject] = [:]
        for (index, component) in urlPathComponents.enumerate() {
            
            let handlerPathComponent = handlerPathComponents[index]
            if handlerPathComponent.isParameter() {
                let parameterName = handlerPathComponent.stringByReplacingOccurrencesOfString("{", withString: "").stringByReplacingOccurrencesOfString("}", withString: "")
                parameters[parameterName] = component
            }
        }
        
        return parameters.count > 0 ? parameters : nil
    }
    
}

extension String {
    
    func isParameter() -> Bool {
        if let startPlaceholderIndex = rangeOfString("{"), let endPlaceholderIndex = rangeOfString("}") {
            let startParenthesisPosition = startIndex.distanceTo(startPlaceholderIndex.startIndex)
            let endParenethesisPosition = startIndex.distanceTo(endPlaceholderIndex.startIndex)
            if startParenthesisPosition == 0 && endParenethesisPosition == characters.count-1 {
                return true
            }
        }
        return false
    }
    
}
