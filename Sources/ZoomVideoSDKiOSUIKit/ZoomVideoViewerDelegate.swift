//
//  ZoomVideoViewerDelegate.swift
//  
//
//  Created by Boon Jun Tan on 25/4/23.
//

import ZoomVideoSDK

public protocol ZoomVideoViewerDelegate: AnyObject {
    func joinedSession(session: String)
    func leftSession(session: String)
}

public extension ZoomVideoViewerDelegate {
    func joinedSession(session: String) {}
    func leftSession(session: String) {}
}
