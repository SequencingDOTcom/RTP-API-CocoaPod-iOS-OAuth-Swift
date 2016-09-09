//
//  SQRequestHelper.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation


class SQRequestHelper : NSObject {
    
    var redirect_uri: String = ""
    
    
    // MARK: - Initializer
    static let instance = SQRequestHelper()
    
    
    // MARK: - custom Saver/Setter
    func rememberRedirectUri(redirect_uri: String) -> Void {
        self.redirect_uri = redirect_uri
    }
    
    
    // MARK: - Request methods
    func verifyRequestForRedirectBack(request: NSURLRequest) -> Bool {
        let currentURL: NSString = request.URL!.absoluteString
        let redirectURL = self.redirect_uri + "?"
        
        if currentURL.containsString(redirectURL) {
            return true
        }
        return false
    }
    
    
    func parseRequest(request: NSURLRequest) -> NSMutableDictionary {
        let dict: NSMutableDictionary = NSMutableDictionary()
        var query = request.URL!.description
        
        if query.containsString("access_denied") {
            dict.setObject(NSNumber(bool: true), forKey: "didCancelAuthorization")
            
        } else if query.containsString("invalid_request") {
            dict.setObject(NSNumber(bool: true), forKey: "error")
            
        } else {
            let array: Array = query.componentsSeparatedByString("?")
            if array.count > 1 {
                query = array.last!
            }
            let params: Array = query.componentsSeparatedByString("&")
            for param in params {
                let elements = param.componentsSeparatedByString("=")
                if elements.count == 2 {
                    let key = elements.first!.stringByRemovingPercentEncoding
                    let val = elements.last!.stringByRemovingPercentEncoding
                    dict.setObject(val!, forKey: key!)
                }
            }
        }
        
        return dict
    }
    
    
    
}