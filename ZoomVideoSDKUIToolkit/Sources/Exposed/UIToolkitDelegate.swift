//
//  UIToolkitDelegate.swift
//  
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation

/// Delegate for UI toolkit event notifications.
@objc public protocol UIToolkitDelegate: AnyObject {
    
    /// Notifies when an error occurred.
    /// - Parameter errorType: Enumeration of all the UI Toolkit errors.
    func onError(_ errorType: UIToolkitError)
    
    /// Notifies when the view is successfully loaded.
    func onViewLoaded()
    
    /// Notifies when the view is successfully dismissed.
    func onViewDismissed()
}

public extension UIToolkitDelegate {
    func onError(_ errorType: UIToolkitError) {}
    func onViewLoaded() {}
    func onViewDismissed() {}
}
