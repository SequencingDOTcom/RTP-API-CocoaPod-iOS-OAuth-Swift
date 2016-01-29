//
//  SQAuthResult.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation

class SQAuthResult: NSObject {
    
    var isAuthorized: Bool = false
    
    var token: SQToken = SQToken() {
        willSet(newToken) {
            token.accessToken = newToken.accessToken
            token.expirationDate = newToken.expirationDate
            token.tokenType = newToken.tokenType
            token.scope = newToken.scope
            
            // DO NOT OVERRIDE REFRESH_TOKEN HERE (after refresh token request it comes as null)
            if newToken.refreshToken != "" {
                token.refreshToken = newToken.refreshToken
            }
        }
        didSet(oldValue) {
            if token.refreshToken == "" {
                token.refreshToken = oldValue.refreshToken
            }
        }
    }
    
    // designated initializer
    static let instance = SQAuthResult()

}
