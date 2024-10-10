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
    public var features: [UIToolkitFeature]?

    /// - Parameters:
    ///   - appGroupId: (Optional) App Group ID for screen sharing.
    public init(appGroupId: String? = nil, features: [UIToolkitFeature]? = nil) {
        self.appGroupId = appGroupId
        self.features = features
    }

    public init(initParamsObject: InitParamsObjC) {
        self.appGroupId = initParamsObject.appGroupId
        self.features = initParamsObject.features
    }
}

/// The initializer parameters object contains information for initializing the ZoomVideoSDK. Objective-C class for interoperability.
@objcMembers public class InitParamsObjC: NSObject {
    /// (Optional) App Group ID for screen sharing.
    public var appGroupId: String?
    public var features: [UIToolkitFeature]?
    
    /// - Parameters:
    ///   - appGroupId: (Optional) App Group ID for screen sharing.
    public init(appGroupId: String? = nil, features: [UIToolkitFeature]? = nil) {
        self.appGroupId = appGroupId
        self.features = features
    }
}
