//
//  SQOAuth.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation


@objc public protocol SQAuthorizationProtocolDelegate: class {
    func userIsSuccessfullyAuthorized(token: SQToken)
    func userIsNotAuthorized()
    
    optional func userDidCancelAuthorization()
}


public protocol SQTokenRefreshProtocolDelegate: class {
    func tokenIsRefreshed(updatedToken: SQToken)
}



public class SQOAuth : NSObject {
    
    public weak var authorizationDelegate: SQAuthorizationProtocolDelegate?
    public var refreshTokenDelegate: SQTokenRefreshProtocolDelegate?
    
    
    // MARK: - Initializer
    public static let instance = SQOAuth()
    
    
    
    // MARK: - Registrate app parameters
    public func registrateApplicationParametersClientID(client_id: String, ClientSecret client_secret: String, RedirectUri redirect_uri: String, Scope scope: String) -> Void {
        SQServerManager.instance.registrateParametersClientID(client_id, ClientSecret: client_secret, RedirectUri: redirect_uri, Scope: scope)
    }
    
    
    
    // MARK: - Authorize user
    public func authorizeUser() -> Void {
        SQServerManager.instance.authorizeUser { (token, didCancel, error) in
            
            if token != nil {
                self.authorizationDelegate?.userIsSuccessfullyAuthorized(token!)
                
            } else if didCancel {
                self.authorizationDelegate?.userDidCancelAuthorization?()
                
            } else if error {
                self.authorizationDelegate?.userIsNotAuthorized()
            }
        }
    }
    
    
    
    // MARK: - Refresh token
    public func updateAccessTokenWithRefreshToken(refreshToken: SQToken, tokenResult:(token: SQToken?) -> Void) -> Void {
        SQServerManager.instance.updateAccessTokenWithRefreshToken(refreshToken) { (token) in
            if token != nil {
                tokenResult(token: token!)
            } else {
                tokenResult(token: nil)
            }
        }
    }
    
    
    
    // MARK: - Token timer updater
    public func launchTokenTimerUpdateWithToken(token: SQToken) -> Void {
        SQServerManager.instance.launchTokenTimerUpdateWithToken(token)
    }
    
    
    
    // MARK: - User sign out
    public func userDidSignOut() -> Void {
        SQServerManager.instance.userDidSignOut()
    }
    
    
}
