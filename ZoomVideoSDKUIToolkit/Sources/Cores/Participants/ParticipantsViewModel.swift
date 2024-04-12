//
//  ParticipantsViewModel.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import ZoomVideoSDK

class ParticipantsViewModel {
    
    private var entryPoint: ParticipantsVCEntryPoint = .ShowInformation
    private var filterText = ""
    
    // Initialization
    
    public init(entryPoint: ParticipantsVCEntryPoint) {
        self.entryPoint = entryPoint
    }
    
    func getLatestParticipantsList() -> [ZoomVideoSDKUser] {
        var participantsList: [ZoomVideoSDKUser] = []
        
        switch entryPoint {
        case .ShowInformation:
            participantsList = UserManager.shared().getAllUsersList()
        case .Chat, .LeaveAndReassignHost:
            participantsList = UserManager.shared().getRemoteUsers()
        }
        
        if !filterText.isEmpty {
            participantsList = participantsList.filter({ ($0.getName() ?? "").contains(filterText) })
        }
        
        return participantsList.sorted(by: { $0.getRolePriority() < $1.getRolePriority() })
    }
    
    public func getParticipantsCount() -> Int {
        return getLatestParticipantsList().count
    }
    
    public func getParticipant(at index: Int) -> ZoomVideoSDKUser? {
        let participantList = getLatestParticipantsList()
        guard index < participantList.count else { return nil }
        return getLatestParticipantsList()[index]
    }
    
    public func setFilterText(text: String) {
        filterText = text
    }
    
}
