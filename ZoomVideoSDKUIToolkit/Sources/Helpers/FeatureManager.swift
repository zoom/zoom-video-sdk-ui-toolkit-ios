//
//  FeatureManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import ZoomVideoSDK

public enum UIToolkitFeature: CaseIterable {
    // case Preview - Future Feature
    case Video
    case Audio
    case ShareScreen
    case Users
    case Chat
    case VirtualBackground
    // case CloudRecording - Future Feature
    case Settings
}

/*
 This Feature Manager class is for developers to select the available UIToolkitFeature that they will like to have in their app.
 Note: Not to confuse with if the user has access to certain feature. E.g. isSupportVirtualBackground.
 Each feature have its own respective manager to check if the local user or remote user has certain permission.
 */
class FeatureManager {
    
    // MARK: - Properties

    private static var featureManager: FeatureManager = {
        let featureManager = FeatureManager()
        
        // Any Other Configuration Below
        
        return featureManager
    }()
    
    // MARK: - Variable
    
    static var availableFeature: [UIToolkitFeature] = []
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Accessors
    
    class func shared() -> FeatureManager {
        return featureManager
    }
    
    public func getAvailableFeature() -> [UIToolkitFeature] {
        return FeatureManager.availableFeature
    }
    
    public func setAvailableFeature(with features: [UIToolkitFeature]) {
        FeatureManager.availableFeature = features
    }
    
    public func setAllAvailableFeature() {
        FeatureManager.availableFeature = UIToolkitFeature.allCases.map({ $0.self })
    }
    
    public func checkIfFeatureIsAvailable(with feature: UIToolkitFeature) -> Bool {
        if FeatureManager.availableFeature.contains(where: { $0 == feature }) {
            return true
        }
        return false
    }
}
