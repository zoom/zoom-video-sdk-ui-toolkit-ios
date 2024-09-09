//
//  FeatureManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import ZoomVideoSDK

enum Feature {
    case Chat
    case ShareScreen
    case VirtualBackground
    case CloudRecording
}

/*
 This Feature Manager class is for local settings on which feature we allow or disallow from the app.
 E.g. If virtual background is ready but we do not want to release it then we can remove it from the manager.
 Note: Not to confuse with if the user has access to certain feature. E.g. isSupportVirtualBackground.
 There will be its own check under its respective class.
 
 Ideally this should be controlled by backend. We might want to implement firebase for this in future.
 */
class FeatureManager {
    
    // MARK: - Properties

    private static var featureManager: FeatureManager = {
        let featureManager = FeatureManager()
        
        // Any Other Configuration Below
        
        return featureManager
    }()
    
    // MARK: - Variable
    
    
    static var availableFeature: [Feature] = []
    
    // MARK: - Initializer
    
    private init() {
        // NOTE: The availableFeature variable controls what feature are available.
        FeatureManager.availableFeature = [.Chat, .VirtualBackground, .ShareScreen] // .CloudRecording
    }
    
    // MARK: - Accessors
    
    class func shared() -> FeatureManager {
        checkNewPermission()
        return featureManager
    }
    
    public func getAvailableFeature() -> [Feature] {
        return FeatureManager.availableFeature
    }
    
    private static func checkNewPermission() {
        availableFeature.removeAll()
        
        if MoreOptionManager.shared().isChatAllowed() {
            availableFeature.append(.Chat)
        }
        
        if MoreOptionManager.shared().isVirtualBackgroundEnabled() {
            availableFeature.append(.VirtualBackground)
        }
    }
    
    public func checkIfFeatureIsAvailable(with feature: Feature) -> Bool {
        if FeatureManager.availableFeature.contains(where: { $0 == feature }) {
            return true
        }
        return false
    }
}
