//
//  SQServerManager.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import UIKit
import Foundation


class SQServerManager: NSObject {
    
    // const for main queue
    let kMainQueue = dispatch_get_main_queue()
    
    // activity indicator with label
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var mainVC = UIViewController()
    
    // registered application parameters
    var client_id: String       = ""
    var client_secret: String   = ""
    var redirect_uri: String    = ""
    var scope: String           = ""
    
    // parameters for authorization request
    let authURL: String         = "https://sequencing.com/oauth2/authorize"
    let response_type: String   = "code"
    let mobileParam: String     = "mobile=1"
    
    // parameters for token request
    let tokenURL: String        = "https://sequencing.com/oauth2/token"
    let grant_type: String      = "authorization_code"
    
    // parameters for refresh token request
    let refreshTokenURL: String   = "https://sequencing.com/oauth2/token?q=oauth2/token"
    let refreshGrant_type: String = "refresh_token"
    
    // parameters for files list request
    let apiURL: String          = "https://api.sequencing.com"
    
    let demoPath: String        = "/DataSourceList?sample=true"
    let filesPath: String       = "/DataSourceList?uploaded=true&shared=true"
    
    
    
    // MARK: - Initializer
    static let instance = SQServerManager()
    
    
    
    // MARK: - Registrate app parameters
    func registrateParametersClientID(client_id: String, ClientSecret client_secret: String, RedirectUri redirect_uri: String, Scope scope: String) -> Void {
        self.client_id = client_id
        self.client_secret = client_secret
        self.redirect_uri = redirect_uri
        self.scope = scope
        SQRequestHelper.instance.rememberRedirectUri(self.redirect_uri)
    }
    
    
    
    // MARK: - Authorization
    func authorizeUser(result: (token: SQToken?, didCancel: Bool, error: Bool) -> Void) -> Void {
        let randomState = self.randomStringWithLength(self.randomInt())
        
        let client_id: String = self.client_id.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        let urlString = authURL + "?" +
            "redirect_uri=" + self.redirect_uri + "&" +
            "response_type=" + self.response_type + "&" +
            "state=" + randomState + "&" +
            "client_id=" + client_id + "&" +
            "scope=" + self.scope + "&" +
            self.mobileParam
        let urlRequest = NSURL(string: urlString)!
        
        // ===== authorizing user request ======
        let loginWebViewController: SQLoginWebViewController = SQLoginWebViewController.init(url: urlRequest) { (response) -> Void in
            print(response)
            
            if response != nil {
                let keys: NSArray = response!.allKeys
                
                if keys.containsObject("state") {
                    // first, must check if "state" from response matches "state" in request
                    let stateInResponse = response?.objectForKey("state") as! String
                    if stateInResponse != randomState {
                        print("state mismatch, response is being spoofed")
                        self.stopActivityIndicator()
                        result(token: nil, didCancel: false, error: true)
                        
                    } else {
                        // state matches - we can proceed with token request
                        // ===== getting token request =====
                        self.startActivityIndicatorWithTitle("Authorizing user")
                        if let codeFromResponse = response?.objectForKey("code") as? String {
                            
                            self.postForTokenWithCode(codeFromResponse, completion: { (token, error) -> Void in
                                if token != nil {
                                    self.stopActivityIndicator()
                                    SQAuthResult.instance.token = token!
                                    SQTokenUpdater.instance.cancelTimer()
                                    // THIS WILL START TIMER TO AUTOMATICALLY REFRESH ACCESS_TOKEN WHEN IT'S EXPIRED
                                    SQTokenUpdater.instance.startTimer()
                                    result(token: token!, didCancel: false, error: false)
                                    
                                } else if error != nil {
                                    print(error)
                                    self.stopActivityIndicator()
                                    result(token: nil, didCancel: false, error: true)
                                }
                            })
                            
                        } else {
                            print("Can't authorize user. Don't forget to register application parameters")
                            self.stopActivityIndicator()
                            result(token: nil, didCancel: false, error: true)
                        }
                    }
                    
                } else if keys.containsObject("didCancelAuthorization") {
                    self.stopActivityIndicator()
                    result(token: nil, didCancel: true, error: false)
                    
                } else if keys.containsObject("error") {
                    self.stopActivityIndicator()
                    result(token: nil, didCancel: false, error: true)
                }
            } else {
                self.stopActivityIndicator()
                result(token: nil, didCancel: false, error: true)
            }
        }
        
        let navigationVC = UINavigationController(rootViewController: loginWebViewController)
        let mainVC = UIApplication.sharedApplication().windows.first!.rootViewController
        mainVC!.presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Refresh token method
    func updateAccessTokenWithRefreshToken(refreshToken: SQToken, refreshedToken: (token: SQToken?) -> Void) -> Void {
        self.postForNewTokenWithRefreshToken(refreshToken) { (updatedToken, error) in
            
            if updatedToken != nil {
                if updatedToken?.refreshToken == nil {
                    updatedToken?.refreshToken = refreshToken.refreshToken
                }
                SQAuthResult.instance.token = updatedToken!
                SQTokenUpdater.instance.cancelTimer()
                // THIS WILL START TIMER TO AUTOMATICALLY REFRESH ACCESS_TOKEN WHEN IT'S EXPIRED
                SQTokenUpdater.instance.startTimer()
                refreshedToken(token: updatedToken!)
                
            } else if error != nil {
                print("error: " + error!.localizedDescription as String)
                refreshedToken(token: nil)
            }
        }
    }
    
    
    
    // MARK: - Timer method
    func launchTokenTimerUpdateWithToken(token: SQToken) -> Void {
        SQAuthResult.instance.token = token
        SQTokenUpdater.instance.cancelTimer()
        // THIS WILL START TIMER TO AUTOMATICALLY REFRESH ACCESS_TOKEN WHEN IT'S EXPIRED
        SQTokenUpdater.instance.startTimer()
    }
    
    
    
    // MARK: - Sign out method
    func userDidSignOut() -> Void {
        let token = SQToken()
        SQAuthResult.instance.token = token
        SQTokenUpdater.instance.cancelTimer()
    }
    
    
    
    // MARK: - Token helper methods
    func postForTokenWithCode(code: String, completion: (token: SQToken?, error: NSError?) -> Void) -> Void {
        let grant_typeString: String = "" + self.grant_type
        let redirect_uriString: String = "" + self.redirect_uri
        let postParameters: [String: String] = ["grant_type": grant_typeString, "code": code, "redirect_uri": redirect_uriString]
        
        SQHttpHelper.instance.execHttpRequestWithUrl(
            self.tokenURL,
            method: "POST",
            headers: nil,
            username: self.client_id,
            password: self.client_secret,
            token: nil,
            authScope: "Basic",
            parameters: postParameters) { (responseText, response, error) -> Void in
                
                if responseText != nil {
                    let jsonData = responseText?.dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        if let jsonParsed = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSDictionary {
                            let token = SQToken()
                            if let value = jsonParsed.objectForKey("access_token") as! String? {
                                token.accessToken = value
                            }
                            if let value = jsonParsed.objectForKey("expires_in") as! String? {
                                let myDouble: NSTimeInterval = Double(value)! - 600
                                token.expirationDate = NSDate(timeIntervalSinceNow: myDouble)
                            }
                            if let value = jsonParsed.objectForKey("token_type") as! String? {
                                token.tokenType = value
                            }
                            if let value = jsonParsed.objectForKey("scope") as! String? {
                                token.scope = value
                            }
                            if let value = jsonParsed.objectForKey("refresh_token") as! String? {
                                token.refreshToken = value
                            }
                            completion(token: token, error: nil)
                        }
                    } catch let error as NSError {
                        print("json error" + error.localizedDescription)
                        completion(token: nil, error: error)
                    }
                } else if error != nil {
                    print("error: " + error!.localizedDescription as String)
                    print("response: ")
                    print(response)
                    completion(token: nil, error: error)
                }
        }
    }
    
    
    func postForNewTokenWithRefreshToken(refreshToken: SQToken, completion: (updatedToken: SQToken?, error: NSError?) -> Void) -> Void {
        let grant_typeString: String    = "" + self.refreshGrant_type
        let refresh_tokenString: String = "" + refreshToken.refreshToken
        let postParameters: [String: String] = ["grant_type": grant_typeString, "refresh_token": refresh_tokenString]
        
        SQHttpHelper.instance.execHttpRequestWithUrl(
            
            self.refreshTokenURL,
            method: "POST",
            headers: nil,
            username: self.client_id,
            password: self.client_secret,
            token: nil,
            authScope: "Basic",
            parameters: postParameters) { (responseText, response, error) -> Void in
                
                if responseText != nil {
                    let jsonData = responseText?.dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        if let jsonParsed = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSDictionary {
                            let token = SQToken()
                            if let value = jsonParsed.objectForKey("access_token") as! String? {
                                token.accessToken = value
                            }
                            if let value = jsonParsed.objectForKey("expires_in") as! String? {
                                let myDouble: NSTimeInterval = Double(value)! - 600
                                token.expirationDate = NSDate(timeIntervalSinceNow: myDouble)
                            }
                            if let value = jsonParsed.objectForKey("token_type") as! String? {
                                token.tokenType = value
                            }
                            if let value = jsonParsed.objectForKey("scope") as! String? {
                                token.scope = value
                            }
                            if let value = jsonParsed.objectForKey("refresh_token") as! String? {
                                token.refreshToken = value
                            }
                            completion(updatedToken: token, error: nil)
                        }
                    } catch let error as NSError {
                        print("json error" + error.localizedDescription)
                        completion(updatedToken: nil, error: error)
                    }
                } else if error != nil {
                    print("json error" + error!.localizedDescription as String)
                    print("response: ")
                    print(response)
                    completion(updatedToken: nil, error: error)
                }
        }
    }
    
    
    
    
    // MARK: - Request helpers (random string and value)
    func randomInt() -> Int {
        return Int(arc4random_uniform(100))
    }
    
    
    func randomStringWithLength(length: Int) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        for _ in (0..<length) {
            let rand = Int(arc4random_uniform(UInt32(base.characters.count)))
            randomString += "\(base[base.startIndex.advancedBy(rand)])"
        }
        
        /*
        for (var i = 0; i < length; i += 1) {
            let rand = Int(arc4random_uniform(UInt32(base.characters.count)))
            randomString += "\(base[base.startIndex.advancedBy(rand)])"
        }*/
        return randomString
    }
    
    
    
    
    // MARK: - Activity indicator
    func startActivityIndicatorWithTitle(title: String) -> Void {
        dispatch_async(kMainQueue) { () -> Void in
            
            let rootVC1 = UIApplication.sharedApplication().windows.first!.rootViewController
            if rootVC1 != nil {
                
                if rootVC1!.isKindOfClass(UINavigationController) {
                    let navigationVC = rootVC1 as! UINavigationController
                    let topmostVC: UIViewController = navigationVC.viewControllers.first!
                    self.mainVC = topmostVC
                } else {
                    self.mainVC = rootVC1!
                }
                
                self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 150, height: 50))
                self.strLabel.text = title
                self.strLabel.textColor = UIColor.grayColor()
                
                let xPos: CGFloat = self.mainVC.view.frame.midX - 100
                let yPos: CGFloat = self.mainVC.view.frame.midY + 50
                self.messageFrame = UIView(frame: CGRect(x: xPos, y: yPos, width: 250, height: 50))
                self.messageFrame.layer.cornerRadius = 15
                self.messageFrame.backgroundColor = UIColor.clearColor()
                
                self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                self.activityIndicator.startAnimating()
                
                self.messageFrame.addSubview(self.activityIndicator)
                self.messageFrame.addSubview(self.strLabel)
                self.mainVC.view.addSubview(self.messageFrame)
            }
        }
    }
    
    
    func stopActivityIndicator() -> Void {
        dispatch_async(kMainQueue) { () -> Void in
            self.activityIndicator.stopAnimating()
            self.messageFrame.removeFromSuperview()
        }
    }
    
    
    
    
    /*
    // MARK: - Genetic files methods
    func getForSampleFilesWithToken(token: SQToken, completion: (sampleFiles: NSArray?, error: NSError?) -> Void) -> Void {
        let apiUrlForSample: String = self.apiURL + self.demoPath
        SQHttpHelper.instance.execHttpRequestWithUrl(
            apiUrlForSample,
            method: "GET",
            headers: nil,
            username: nil,
            password: nil,
            token: token.accessToken,
            authScope: "Bearer",
            parameters: nil) { (responseText, response, error) -> Void in
                if responseText != nil {
                    let jsonData = responseText?.dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        if let jsonParsed = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSArray {
                            completion(sampleFiles: jsonParsed, error: nil)
                        }
                    } catch let error as NSError {
                        print("json error" + error.localizedDescription)
                        completion(sampleFiles: nil, error: error)
                    }
                } else if error != nil {
                    print("error: ")
                    print(error)
                    print("response: ")
                    print(response)
                    completion(sampleFiles: nil, error: error)
                }
        }
    }
    
    
    func getForOwnFilesWithToken(token: SQToken, completion: (ownFiles: NSArray?, error: NSError?) -> Void) -> Void {
        let apiUrlForFiles: String = self.apiURL + self.filesPath
        SQHttpHelper.instance.execHttpRequestWithUrl(
            apiUrlForFiles,
            method: "GET",
            headers: nil,
            username: nil,
            password: nil,
            token: token.accessToken,
            authScope: "Bearer",
            parameters: nil) { (responseText, response, error) -> Void in
                if responseText != nil {
                    let jsonData = responseText?.dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        if let jsonParsed = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSArray {
                            completion(ownFiles: jsonParsed, error: nil)
                        }
                    } catch let error as NSError {
                        print("json error" + error.localizedDescription)
                        completion(ownFiles: nil, error: error)
                    }
                } else if error != nil {
                    print("error: ")
                    print(error)
                    print("response: ")
                    print(response)
                    completion(ownFiles: nil, error: error)
                }
        }
    }
 */

}
