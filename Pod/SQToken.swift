//
//  SQToken.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation

public class SQToken: NSObject, NSCoding {
    
    public var accessToken     = String()
    public var expirationDate  = NSDate()
    public var tokenType       = String()
    public var scope           = String()
    public var refreshToken    = String()
    
    
    // MARK: - Init
    override init() {
    }
    
    
    // MARK: - NSCoding protocol
    public required init(coder aDecoder: NSCoder) {
        self.accessToken    = aDecoder.decodeObjectForKey("accessToken") as! String
        self.expirationDate = aDecoder.decodeObjectForKey("expirationDate") as! NSDate
        self.tokenType      = aDecoder.decodeObjectForKey("tokenType") as! String
        self.scope          = aDecoder.decodeObjectForKey("scope") as! String
        self.refreshToken   = aDecoder.decodeObjectForKey("refreshToken") as! String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.accessToken, forKey: "accessToken")
        aCoder.encodeObject(self.expirationDate, forKey: "expirationDate")
        aCoder.encodeObject(self.tokenType, forKey: "tokenType")
        aCoder.encodeObject(self.scope, forKey: "scope")
        aCoder.encodeObject(self.refreshToken, forKey: "refreshToken")
    }

}
