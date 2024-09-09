//
//  InitParams.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.
//

import UIKit

/// The initializer parameters object contains information for initializing the ZoomVideoSDK.
public struct InitParams {
    /// (Optional) App Group ID for screen sharing.
    public var appGroupId: String?

    /// - Parameters:
    ///   - appGroupId: (Optional) App Group ID for screen sharing.
    public init(appGroupId: String? = nil) {
        self.appGroupId = appGroupId
    }

    public init(initParamsObject: InitParamsObjC) {
        self.appGroupId = initParamsObject.appGroupId
    }
}

/// The initializer parameters object contains information for initializing the ZoomVideoSDK. Objective-C class for interoperability.
@objcMembers public class InitParamsObjC: NSObject {
    /// (Optional) App Group ID for screen sharing.
    public var appGroupId: String?
    
    /// - Parameters:
    ///   - appGroupId: (Optional) App Group ID for screen sharing.
    public init(appGroupId: String? = nil) {
        self.appGroupId = appGroupId
    }
}
