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
    internal fileprivate(set) var path: String! {
        didSet {
            updatePathComponents()
        }
    }
    internal fileprivate(set) var block: URIHandlerBlock!
    
    fileprivate var pathComponents: [String]!
    
    init(path: String, block: @escaping URIHandlerBlock) {
        self.path = path
        self.block = block
        updatePathComponents()
    }
    
    fileprivate func updatePathComponents() {
        pathComponents = path.components(separatedBy: "/")
    }
    
    func matchURL(_ url: URL) -> Bool {
        
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
        
        for (index, component) in pathComponents.enumerated() {
            if component.isParameter {
                continue
            }
            if urlPathComponents[index] != component {
                return false
            }
        }
        
        return true
    }
    
    func parametersURL(_ url: URL) -> [String: String]? {
        
        let urlPathComponents = url.urlPathComponents
        
        var parameters: [String: String] = [:]
        for (index, component) in pathComponents.enumerated() {
            
            if component.isParameter {
                let parameterName = component.parameterNameString
                parameters[parameterName] = urlPathComponents[index]
            }
            
        }
        
        return parameters.count > 0 ? parameters : nil
    }

}

extension URL {
    
    var urlPathComponents: [String] {
        let pathComponentsString = (host ?? "") + (path ?? "")
        return pathComponentsString.components(separatedBy: "/")
    }
    
}

extension String {
    
    var isParameter: Bool {
        if let startPlaceholderIndex = range(of: "{"), let endPlaceholderIndex = range(of: "}") {
            let startParenthesisPosition = characters.distance(from: startIndex, to: startPlaceholderIndex.lowerBound)
            let endParenethesisPosition = characters.distance(from: startIndex, to: endPlaceholderIndex.lowerBound)
            if startParenthesisPosition == 0 && endParenethesisPosition == characters.count-1 {
                return true
            }
        }
        return false
    }
    
    var parameterNameString: String {
        return replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
    }
    
}
