//
//  ZoomVideoSDKUser+Extension.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import ZoomVideoSDK

extension ZoomVideoSDKUser {
    func getNameWithRole() -> String {
        guard let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return "" }
        let username = self.getName() ?? ""
        
        let isMyself = myself == self
        
        var userRole = ""
        if self.isHost() {
            userRole = " - Host"
        } else if self.isManager() {
            userRole = " - Manager"
        }
        
        return username + (isMyself ? " (Me)" : "") + userRole
    }
    
    func getRolePriority() -> Int {
        guard let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return -1 }
        let isMyself = myself == self
        
        if isMyself { return 0 }
        if self.isHost() { return 1 }
        if self.isManager() { return 2 }
        return 3
    }
}
