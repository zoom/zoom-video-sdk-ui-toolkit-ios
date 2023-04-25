//
//  ZoomConnectionData.swift
//  
//
//  Created by Boon Jun Tan on 25/4/23.
//

import UIKit

public struct ZoomConnectionData {
    
    public var sdkKey: String
    public var sdkSecret: String
    
    public init(sdkKey: String, sdkSecret: String) {
        self.sdkKey = sdkKey
        self.sdkSecret = sdkSecret
    }
}
