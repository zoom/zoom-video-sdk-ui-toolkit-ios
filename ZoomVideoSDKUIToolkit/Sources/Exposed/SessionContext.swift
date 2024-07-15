//
//  SessionContext.swift
//  
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

/// The session context consists of information required to start or join a session.
public struct SessionContext {
    /// Video SDK JWT to start or join a session.
    public var jwt: String
    /// Session name
    public var sessionName: String
    /// (Optional) Password to start or join a session.
    public var sessionPassword: String?
    /// Username to display and identify each individual.
    public var username: String
    
    /// - Parameters:
    ///   - jwt: The generated Video SDK JWT to authorize starting or joining a session.
    ///   - sessionName: The name of the session. The string length must be less than 150. Supported character scopes are: Letters, numbers, spaces, and the following characters: "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", "{", "}", "|", "~", ",".
    ///   - sessionPassword: (Optional) Password to start or join a session.
    ///   - username: Name to display and identify each individual.
    public init(jwt: String, sessionName: String, sessionPassword: String? = nil, username: String) {
        self.jwt = jwt
        self.sessionName = sessionName
        self.sessionPassword = sessionPassword
        self.username = username
    }

    public init(sessionContextObject: SessionContextObjC) {
        self.jwt = sessionContextObject.jwt
        self.sessionName = sessionContextObject.sessionName
        self.sessionPassword = sessionContextObject.sessionPassword
        self.username = sessionContextObject.username
    }
}

/// The session context consists of information required to start or join a session. Objective-C class for interoperability.
@objcMembers public class SessionContextObjC: NSObject {
    /// Video SDK JWT to start or join a session.
    public var jwt: String
    /// Session name
    public var sessionName: String
    /// (Optional) Password to start or join a session.
    public var sessionPassword: String?
    /// Username to display and identify each individual.
    public var username: String

    /// - Parameters:
    ///   - jwt: The generated Video SDK JWT to authorize starting or joining a session.
    ///   - sessionName: The name of the session. The string length must be less than 150. Supported character scopes are: Letters, numbers, spaces, and the following characters: "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", "{", "}", "|", "~", ",".
    ///   - sessionPassword: (Optional) Password to start or join a session.
    ///   - username: Name to display and identify each individual.
    public init(jwt: String, sessionName: String, sessionPassword: String? = nil, username: String) {
        self.jwt = jwt
        self.sessionName = sessionName
        self.sessionPassword = sessionPassword
        self.username = username
    }
}
