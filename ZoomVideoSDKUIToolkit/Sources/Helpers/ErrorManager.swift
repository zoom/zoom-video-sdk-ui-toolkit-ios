//
//  ErrorManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

class ErrorManager {
    
    // MARK: - Properties
    
    private static var errorManager: ErrorManager = {
        let errorManager = ErrorManager()
        
        // Any Other Configuration Below
        
        return errorManager
    }()
    
    // MARK: - Variable
    private weak var delegate: UIToolkitDelegate?
    
    // MARK: - Initializer
    
    private init() {
        
    }
    
    // MARK: - Accessors
    
    class func shared() -> ErrorManager {
        return errorManager
    }
    
    public func getDelegate() -> UIToolkitDelegate? {
        return delegate
    }
    
    public func setDelegate(with delegate: UIToolkitDelegate) {
        self.delegate = delegate
    }
    
}
