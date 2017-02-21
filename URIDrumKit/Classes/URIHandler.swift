//
//  URIHandler.swift
//  Pods
//
//  Created by Fabio Borella on 21/02/17.
//
//

import Foundation

class URIHandler {
    
    internal var scheme: String?
    internal private(set) var path: String! {
        didSet {
            updatePathComponents()
        }
    }
    internal private(set) var block: URIHandlerBlock!
    
    private var pathComponents: [String]!
    
    init(path: String, block: URIHandlerBlock) {
        self.path = path
        self.block = block
        updatePathComponents()
    }
    
    private func updatePathComponents() {
        pathComponents = path.componentsSeparatedByString("/")
    }
    
    func matchURL(url: NSURL) -> Bool {
        
        if let scheme = scheme {
            guard url.scheme == scheme else {
                return false
            }
        } else {
            guard url.scheme == URIManager.scheme else {
                return false
            }
        }
        
        let urlPathComponents = url.urlPathComponents
        
        guard urlPathComponents.count == pathComponents.count else {
            return false
        }
        
        for (index, component) in pathComponents.enumerate() {
            if component.isParameter {
                continue
            }
            if urlPathComponents[index] != component {
                return false
            }
        }
        
        return true
    }
    
    func parametersURL(url: NSURL) -> [String: String]? {
        
        let urlPathComponents = url.urlPathComponents
        
        var parameters: [String: String] = [:]
        for (index, component) in pathComponents.enumerate() {
            
            if component.isParameter {
                let parameterName = component.parameterNameString
                parameters[parameterName] = urlPathComponents[index]
            }
            
        }
        
        return parameters.count > 0 ? parameters : nil
    }

}

extension NSURL {
    
    var urlPathComponents: [String] {
        let pathComponentsString = (host ?? "") + (path ?? "")
        return pathComponentsString.componentsSeparatedByString("/")
    }
    
}

extension String {
    
    var isParameter: Bool {
        if let startPlaceholderIndex = rangeOfString("{"), let endPlaceholderIndex = rangeOfString("}") {
            let startParenthesisPosition = startIndex.distanceTo(startPlaceholderIndex.startIndex)
            let endParenethesisPosition = startIndex.distanceTo(endPlaceholderIndex.startIndex)
            if startParenthesisPosition == 0 && endParenethesisPosition == characters.count-1 {
                return true
            }
        }
        return false
    }
    
    var parameterNameString: String {
        return stringByReplacingOccurrencesOfString("{", withString: "").stringByReplacingOccurrencesOfString("}", withString: "")
    }
    
}
