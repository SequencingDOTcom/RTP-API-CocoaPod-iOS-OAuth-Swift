//
//  SQAPI.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import Foundation

class SQAPI: NSObject {
    
    // designated initializer
    static let instance = SQAPI()
    
    
    // MARK: - API methods
    func loadOwnFiles(result: (files: NSArray?) -> Void) -> Void {
        SQServerManager.instance.getForOwnFilesWithToken(SQAuthResult.instance.token) { (ownFiles, error) -> Void in
            if ownFiles != nil {
                result(files: ownFiles!)
            } else {
                result(files: nil)
            }
        }
    }
    
    
    func loadSampleFiles(result: (files: NSArray?) -> Void) -> Void {
        SQServerManager.instance.getForSampleFilesWithToken(SQAuthResult.instance.token) { (sampleFiles, error) -> Void in
            if sampleFiles != nil {
                result(files: sampleFiles!)
            } else {
                result(files: nil)
            }
        }
    }
    
}
