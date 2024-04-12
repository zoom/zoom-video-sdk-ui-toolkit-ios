//
//  PermissionManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import AVFoundation
import UIKit

class PermissionManager {
    
    // MARK: - Properties

    private static var permissionManager: PermissionManager = {
        let permissionManager = PermissionManager()
        
        // Any Other Configuration Below
        
        return permissionManager
    }()
    
    // MARK: - Variable
    
    
    
    // MARK: - Initializer
    
    private init() {
        
    }
    
    // MARK: - Accessors
    
    class func shared() -> PermissionManager {
        return permissionManager
    }
    
    public func checkIfMicAndCameraPermissionsGranted() -> Bool {
        return cameraPermissionGranted() && requestMicrophonePermission()
    }
    
    private func cameraPermissionGranted() -> Bool {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Simulator does not have camera feature so return true immediately
        #if targetEnvironment(simulator)
        return true
        #else
        switch cameraAuthorizationStatus {
        case .notDetermined, .authorized:
            return true // Let VSDK handle
        default:
            ErrorManager.shared().getDelegate()?.onError(.NoCameraPermission)
            DispatchQueue.main.async {
                if let topVC = UIApplication.topViewController() {
                    topVC.alertError(with: .NoCameraPermission, dismiss: true)
                }
            }
            return false
        }
        #endif
    }
    
    private func requestMicrophonePermission() -> Bool {
        let microphoneAuthorizationStatus = AVAudioSession.sharedInstance().recordPermission
        
        // Seem like in our VSDK we don't have to manually request for microphone permission and it still works.
        #if targetEnvironment(simulator)
        return true
        #else
        switch microphoneAuthorizationStatus {
        case .undetermined, .granted:
            return true // Let VSDK handle
        default:
            ErrorManager.shared().getDelegate()?.onError(.NoMicrophonePermission)
            DispatchQueue.main.async {
                if let topVC = UIApplication.topViewController() {
                    topVC.alertError(with: .NoMicrophonePermission, dismiss: true)
                }
            }
            return false
        }
        #endif
    }
}
