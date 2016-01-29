//
//  SQToken.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation

class SQToken: NSObject {
    
    var accessToken     = String()
    var expirationDate  = NSDate()
    var tokenType       = String()
    var scope           = String()
    var refreshToken    = String()

}
