//
//  ChatManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import ZoomVideoSDK

protocol ChatManagerDelegate: AnyObject {
    func chatPrivilegeChanged(enabled: Bool)
    func newChatParticipantSelected()
}

extension ChatManagerDelegate {
    func chatPrivilegeChanged(enabled: Bool) {}
    func newChatParticipantSelected() {}
}

extension Notification.Name {
    static let unreadMessageRead = Notification.Name("unreadMessageRead")
    static let newMessageReceived = Notification.Name("newMessageReceived")
}

class ChatManager {
    
    // MARK: - Properties

    private static var chatManager: ChatManager = {
        let chatManager = ChatManager()
        
        // Any Other Configuration Below
        
        return chatManager
    }()
    
    // MARK: - Variable
    
    private var chatPriviledge: ZoomVideoSDKChatPrivilegeType = .no_One
    private var chatMessages: [ZoomVideoSDKChatMessage] = []
    private var unreadChatMessages: [ZoomVideoSDKChatMessage] = []
    private var chatHelper: ZoomVideoSDKChatHelper?
    private var selectedParticipant: ZoomVideoSDKUser?
    
    weak var delegate: ChatManagerDelegate?
    
    // MARK: - Initializer
    
    private init() {
        guard let chatHelper = ZoomVideoSDK.shareInstance()?.getChatHelper() else { return }
        self.chatHelper = chatHelper
        self.chatPriviledge = chatHelper.getChatPrivilege()
    }
    
    // MARK: - Accessors
    
    class func shared() -> ChatManager {
        return chatManager
    }
    
    public func getChatMessages() -> [ZoomVideoSDKChatMessage] {
        return chatMessages
    }
    
    public func getMessage(at index: Int) -> ZoomVideoSDKChatMessage? {
        guard index < chatMessages.count else { return nil }
        return chatMessages[index]
    }
    
    public func getUnreadMessageCount() -> Int {
        return unreadChatMessages.count
    }
    
    public func resetUnreadMessage() {
        unreadChatMessages = []
        NotificationCenter.default.post(name: .unreadMessageRead, object: nil)
    }
    
    public func getSendParticipant() -> ZoomVideoSDKUser? {
        return selectedParticipant
    }
    
    public func selectSendParticipant(user: ZoomVideoSDKUser? = nil) {
        if user == nil {
            selectedParticipant = nil
        } else {
            selectedParticipant = user
        }
        delegate?.newChatParticipantSelected()
    }
    
    public func resetSelectedParticipant() {
        selectedParticipant = nil
        delegate?.newChatParticipantSelected()
    }
    
    public func sendChat(text: String) -> Bool {
        guard let chatHelper = ZoomVideoSDK.shareInstance()?.getChatHelper(), !chatHelper.isChatDisabled() else { return false }
        if selectedParticipant == nil {
            let result = chatHelper.sendChat(toAll: text)
            if result != .Errors_Success {
                guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return false }
                ErrorManager.shared().getDelegate()?.onError(.SendGroupMessageFailed)
                topVC.alertError(with: .SendGroupMessageFailed, dismiss: false)
            }
            return result == .Errors_Success
        } else {
            let result = chatHelper.sendChat(to: selectedParticipant, content: text)
            if result != .Errors_Success {
                guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return false }
                ErrorManager.shared().getDelegate()?.onError(.SendPrivateMessageFailed)
                topVC.alertError(with: .SendPrivateMessageFailed, dismiss: false)
            }
            return result == .Errors_Success
        }
    }
    
    public func addNewChat(chatMessage: ZoomVideoSDKChatMessage) {
        chatMessages.append(chatMessage)
        if let topVC = UIApplication.topViewController(), !topVC.isKind(of: ChatVC.self) {
            unreadChatMessages.append(chatMessage)
        }
        NotificationCenter.default.post(name: .newMessageReceived, object: nil)
    }
    
    public func isChatEnabled() -> Bool {
        switch chatPriviledge {
        case .everyone_Publicly_And_Privately:
            return true
        default:
            return false
        }
    }
    
    public func changeChatPriviledge(priviledge: ZoomVideoSDKChatPrivilegeType) {
        chatPriviledge = priviledge
        delegate?.chatPrivilegeChanged(enabled: isChatEnabled())
    }
    
}
