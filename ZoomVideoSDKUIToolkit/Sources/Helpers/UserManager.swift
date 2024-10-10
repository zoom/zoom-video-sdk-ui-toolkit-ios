//
//  UserManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import ZoomVideoSDK

protocol UserManagerDelegate: AnyObject {
    func addedRemoteUser(index: Int)
    func updatedRemoteUser(index: Int)
    func removedRemoteUser(index: Int)
    func mutedCurrentUser(index: Int)
    func updatedLocalUser()
    func unmutedLocalUser()
    func changedHost()
    func changedManager()
}

enum UserControlEntry {
    case ManageUserAudio
    case MuteAllUsers
    case UnmuteAllUsers
    case MakeHost
    case ManageManager
    case ChangeName
    case RemoveUser
}

class UserManager {
    
    // MARK: - Properties
    
    private static var userManager: UserManager = {
        let userManager = UserManager()
        
        // Any Other Configuration Below
        
        return userManager
    }()
    
    // MARK: - Variable
    
    private var localUser: ZoomVideoSDKUser?
    private var remoteUsersList: [ZoomVideoSDKUser] = []
    
    private var sheetView = CustomBottomSheetView()
    private var selectedUser: ZoomVideoSDKUser!
    
    weak var delegate: UserManagerDelegate?
    
    private var userControlEntry: UserControlEntry?
    
    // MARK: - Initializer
    
    private init() {
        _ = getLocalUser()
        _ = getRemoteUsers()
    }
    
    // MARK: - Accessors
    
    class func shared() -> UserManager {
        return userManager
    }
    
    // LOCAL USER
    
    public func getLocalUser() -> ZoomVideoSDKUser? {
        guard let localUser = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return nil }
        self.localUser = localUser
        return localUser
    }
    
    public func updateLocalUser(with user: ZoomVideoSDKUser) {
        self.localUser = user
        delegate?.updatedLocalUser()
    }
    
    public func isLocalUserHost() -> Bool {
        guard let localUser = localUser else { return false }
        return localUser.isHost()
    }
    
    public func isLocalUserManager() -> Bool {
        guard let localUser = localUser else { return false }
        return localUser.isManager()
    }
    
    public func isLocalUserHostOrManager() -> Bool {
        guard let localUser = localUser else { return false }
        return localUser.isHost() || localUser.isManager()
    }
    
    public func unmuteLocalUser() {
        guard let localUser = localUser, let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() else { return }
        audioHelper.unmuteAudio(localUser)
    }
    
    // REMOTE USERS
    
    public func getRemoteUsers() -> [ZoomVideoSDKUser] {
        return remoteUsersList
    }
    
    public func addRemoteUsers(with user: ZoomVideoSDKUser) {
        remoteUsersList.append(user)
        delegate?.addedRemoteUser(index: remoteUsersList.count - 1)
    }
    
    public func removeRemoteUsers(with user: ZoomVideoSDKUser) {
        guard let userInList = remoteUsersList.first(where: { $0.getID() == user.getID() }), let userIndex = remoteUsersList.firstIndex(of: userInList) else { return }
        remoteUsersList.remove(at: userIndex)
        delegate?.removedRemoteUser(index: userIndex)
    }
    
    public func updateRemoteUser(with user: ZoomVideoSDKUser) {
        guard let userInList = remoteUsersList.first(where: { $0.getID() == user.getID() }), let userIndex = remoteUsersList.firstIndex(of: userInList) else { return }
        remoteUsersList[userIndex] = user
        delegate?.updatedRemoteUser(index: userIndex)
    }
    
    // ALL USERS
    
    public func getAllUsersList() -> [ZoomVideoSDKUser] {
        guard let localUser = getLocalUser() else { return [] }
        var usersList:[ZoomVideoSDKUser] = []
        usersList = getRemoteUsers()
        usersList.insert(localUser, at: 0)
        return usersList
    }
    
    public func presentMuteUsersUI() {
        guard let vc = UIApplication.topViewController() else { return }
        userControlEntry = .MuteAllUsers
        let alertBox = CustomAlertBox()
        alertBox.delegate = self
        alertBox.setButton(title: "Mute all participants")
        vc.view.addSubview(alertBox)
        alertBox.fitLayoutTo(view: vc.view)
        alertBox.present()
    }
    
    public func askAllUsersToUnmute() {
        guard let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() else { return }
        let allUsersList = getAllUsersList()
        var unmuteRequestSentToAll = true
        for i in 0...allUsersList.count - 1 {
            if let userIsMuted = allUsersList[i].audioStatus()?.isMuted, userIsMuted {
                let result = audioHelper.unmuteAudio(allUsersList[i])
                if result == .Errors_Success {
                    // Note: All users including local user and remote users will trigger success
                    // Errors_Success == local user's mic is unmute
                    // Errors_Success == remote user's onHostAskUnmute triggered
                    if i == 0 {
                        localUser?.audioStatus()?.isMuted = false
                        delegate?.unmutedLocalUser()
                    }
                } else {
                    unmuteRequestSentToAll = false
                }
            }
        }
        if unmuteRequestSentToAll {
            Toast.show(message: "Your request has been sent.")
        } else {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.RequestToUnmuteEveryoneFailed)
            topVC.alertError(with: .RequestToUnmuteEveryoneFailed, dismiss: false)
        }
    }
    
    // MARK: SINGLE USER FUNCTION
    
    // Role Related
    
    public func isUserHost(with user: ZoomVideoSDKUser) -> Bool {
        return user.isHost()
    }
    
    public func isUserManager(with user: ZoomVideoSDKUser) -> Bool {
        return user.isManager()
    }
    
    public func isLocalUserAlreadyManager(with user: ZoomVideoSDKUser) -> Bool {
        guard let localUser = localUser else { return false }
        if localUser.getID() == user.getID(), localUser.isManager() {
            return true
        }
        
        guard let userInList = remoteUsersList.first(where: { $0.getID() == user.getID() }), let userIndex = remoteUsersList.firstIndex(of: userInList) else { return false }
        if remoteUsersList[userIndex].isManager() {
            return true
        }
        
        return false
    }
    
    public func isUserHostOrManager(with user: ZoomVideoSDKUser) -> Bool {
        return user.isHost() || user.isManager()
    }
    
    public func isUserMyself(with user: ZoomVideoSDKUser) -> Bool {
        return localUser == user
    }
    
    public func assignNewHost(at index: Int, _ completion: @escaping (_ success: Bool) -> Void) {
        let user = remoteUsersList[index]
        if let success = ZoomVideoSDK.shareInstance()?.getUserHelper()?.makeHost(user), success {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    public func updateHost(with user: ZoomVideoSDKUser) {
        if localUser?.getID() == user.getID() {
            localUser = user
        } else {
            guard let userInList = remoteUsersList.first(where: { $0.getID() == user.getID() }), let userIndex = remoteUsersList.firstIndex(of: userInList) else { return }
            remoteUsersList[userIndex] = user
        }
        delegate?.changedHost()
    }
    
    public func updateManager(with user: ZoomVideoSDKUser) {
        if localUser?.getID() == user.getID() {
            localUser = user
        } else {
            guard let userInList = remoteUsersList.first(where: { $0.getID() == user.getID() }), let userIndex = remoteUsersList.firstIndex(of: userInList) else { return }
            remoteUsersList[userIndex] = user
        }
        delegate?.changedManager()
    }
    
    // Audio Related
    
    public func isUserMicOn(with user: ZoomVideoSDKUser) -> Bool {
        guard let userMuted = user.audioStatus()?.isMuted else { return false }
        return !userMuted
    }
    
    // Video Related
    
    public func isUserVideoOn(with user: ZoomVideoSDKUser) -> Bool {
        guard let userVideoOn = user.getVideoCanvas()?.videoStatus()?.on else { return false }
        return userVideoOn
    }
    
    // Selected User - User Control and its functionality
    
    public func showUserControlUI(with user: ZoomVideoSDKUser) {
        guard let vc = UIApplication.topViewController() else { return }
        self.selectedUser = user
        
        sheetView = CustomBottomSheetView()
        
        // Note: Local user is unable to click his/her own name under ParticipantsVC
        
        let userNameView = CustomBottomSheetCTAView()
        userNameView.setButton(title: user.getName() ?? "", titleBold: true, action: nil)
        sheetView.ctaStackView.addArrangedSubview(userNameView)
        
        sheetView.ctaStackView.addArrangedSubview(getAudioControlUI())
        
        if isLocalUserHost() {
            sheetView.ctaStackView.addArrangedSubview(getMakeHostUI())
            sheetView.ctaStackView.addArrangedSubview(getManageManagerUI())
            sheetView.ctaStackView.addArrangedSubview(getChangeNameUI())
        } else if isLocalUserManager() && !selectedUser.isManager() && !selectedUser.isHost() {
            sheetView.ctaStackView.addArrangedSubview(getChangeNameUI())
        }
        
        if isLocalUserHost() || (isLocalUserManager() && !isUserHostOrManager(with: selectedUser)) {
            sheetView.ctaStackView.addArrangedSubview(getRemoveSessionUI())
        }
        
        vc.view.addSubview(sheetView)
        sheetView.fitLayoutTo(view: vc.view)
        sheetView.present()
    }
    
    private func getAudioControlUI() -> CustomBottomSheetCTAView {
        let audioView = CustomBottomSheetCTAView()
        let isUserMicOn = isUserMicOn(with: selectedUser)
        audioView.setButton(image: isUserMicOn ? "Mic-Disabled-NoFill" : "Mic-NoFill", title: isUserMicOn ? "Mute audio" : "Request to unmute audio", action: isUserMicOn ? muteSelectedUser : requestToUnmuteSelectedUser)
        return audioView
    }
    
    private func muteSelectedUser() {
        sheetView.dismiss()
        userControlEntry = .ManageUserAudio
        guard let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() else { return }
        let result = audioHelper.muteAudio(selectedUser)
        if result == .Errors_Success {
            Toast.show(message: "\(selectedUser?.getName() ?? "nil") has been muted.")
        } else {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.MuteSingleParticipantFailed)
            topVC.alertError(with: .MuteSingleParticipantFailed, dismiss: false)
        }
    }
    
    private func requestToUnmuteSelectedUser() {
        sheetView.dismiss()
        userControlEntry = .ManageUserAudio
        guard let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() else { return }
        let result = audioHelper.unmuteAudio(selectedUser)
        if result == .Errors_Success {
            Toast.show(message: "Your request to unmute \(selectedUser?.getName() ?? "nil") has been sent.")
        } else {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.RequestToUnmuteSingleParticipantFailed)
            topVC.alertError(with: .RequestToUnmuteSingleParticipantFailed, dismiss: false)
        }
    }
    
    private func getMakeHostUI() -> CustomBottomSheetCTAView {
        let hostView = CustomBottomSheetCTAView()
        hostView.setButton(image: "Avatar", title: "Make host", action: makeSelectedUserHost)
        return hostView
    }
    
    private func makeSelectedUserHost() {
        sheetView.dismiss()
        userControlEntry = .MakeHost
        let result = ZoomVideoSDK.shareInstance()?.getUserHelper()?.makeHost(selectedUser) ?? false
        if result {
            // Do nothing as onUserHostChanged will be called
        } else {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.ChangeHostFailed)
            topVC.alertError(with: .ChangeHostFailed, dismiss: false)
        }
    }
    
    private func getManageManagerUI() -> CustomBottomSheetCTAView {
        let userIsManager = isUserManager(with: selectedUser)
        let managerView = CustomBottomSheetCTAView()
        managerView.setButton(image: "Avatar", title: userIsManager ? "Revoke manager" : "Make manager", action: makeSelectedUserManager)
        return managerView
    }
    
    private func makeSelectedUserManager() {
        sheetView.dismiss()
        userControlEntry = .ManageManager
        var result: Bool // true = success
        var error: UIToolkitError
        
        if selectedUser.isManager() {
            result = ZoomVideoSDK.shareInstance()?.getUserHelper()?.revokeManager(selectedUser) ?? false
            error = .RevokeManagerFailed
        } else {
            result = ZoomVideoSDK.shareInstance()?.getUserHelper()?.makeManager(selectedUser) ?? false
            error = .GrantManagerFailed
        }
        
        if result {
            // Do nothing as onUserManagerChanged will be called
        } else {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(error)
            topVC.alertError(with: error, dismiss: false)
        }
    }
    
    private func getChangeNameUI() -> CustomBottomSheetCTAView {
        let changeNameView = CustomBottomSheetCTAView()
        changeNameView.setButton(image: "Edit", title: "Change name", action: showChangeNameAlert)
        return changeNameView
    }
    
    private func showChangeNameAlert() {
        sheetView.dismiss()
        userControlEntry = .ChangeName
        guard let vc = UIApplication.topViewController() else { return }
        let alertBox = CustomAlertBox()
        alertBox.delegate = self
        alertBox.setButton(title: "Change name in session", textFieldPlaceholder: selectedUser.getName() ?? "Nil")
        vc.view.addSubview(alertBox)
        alertBox.fitLayoutTo(view: vc.view)
        alertBox.present()
    }
    
    private func getRemoveSessionUI() -> CustomBottomSheetCTAView {
        let removeSessionView = CustomBottomSheetCTAView()
        removeSessionView.setButton(image: "Avatar-Clear", title: "Remove from session", textColor: UIColor(red: 213/255, green: 73/255, blue: 65/255, alpha: 1), action: showConfirmRemoveUI)
        return removeSessionView
    }
    
    private func showConfirmRemoveUI() {
        guard let vc = UIApplication.topViewController() else { return }
        sheetView.dismiss()
        userControlEntry = .RemoveUser
        let customAlertUI = CustomAlertBox()
        customAlertUI.setButton(title: "Remove \(selectedUser.getName() ?? "Nil") from session.", description: "Once you remove this user from the session, the user will not be able to join the session again.")
        customAlertUI.delegate = self
        vc.view.addSubview(customAlertUI)
        customAlertUI.fitLayoutTo(view: vc.view)
        customAlertUI.present()
    }

    private func removeFromSession() {
        let result = ZoomVideoSDK.shareInstance()?.getUserHelper()?.remove(selectedUser) ?? false
        if result {
            Toast.show(message: "\(selectedUser.getName() ?? "Nil") has been removed from session.")
        } else {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.RemoveParticipantFailed)
            topVC.alertError(with: .RemoveParticipantFailed, dismiss: false)
        }
    }
}

extension UserManager: CustomAlertBoxDelegate {
    func onClickConfirmBtn() {
        switch userControlEntry {
        case .MuteAllUsers:
            guard let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() else { return }
            var mutedAllSuccessfully = true
            let allUsersList = getAllUsersList()
            for i in 0...allUsersList.count - 1 {
                if let userIsMuted = allUsersList[i].audioStatus()?.isMuted, !userIsMuted {
                    let result = audioHelper.muteAudio(allUsersList[i])
                    if result == .Errors_Success {
                        delegate?.mutedCurrentUser(index: i)
                        if i == 0 {
                            localUser?.audioStatus()?.isMuted = true
                        } else {
                            remoteUsersList[i-1].audioStatus()?.isMuted = true
                        }
                    } else {
                        mutedAllSuccessfully = false
                    }
                }
            }
            if !mutedAllSuccessfully {
                guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
                ErrorManager.shared().getDelegate()?.onError(.MuteEveryoneFailed)
                topVC.alertError(with: .MuteEveryoneFailed, dismiss: false)
            } else {
                Toast.show(message: "All participants are muted.")
            }
        case .RemoveUser:
            removeFromSession()
        default:
            break
        }
    }
    
    func onClickConfirmBtnWithTextField(text: String) {
        guard let userHelper = ZoomVideoSDK.shareInstance()?.getUserHelper() else { return }
        let result = userHelper.changeName(text, with: selectedUser)
        if result {
            // Do nothing as onUserHostChanged will be called to handle UI change
            Toast.show(message: "The host has changed your name.")
        } else {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.ChangeSingleParticipantNameFailed)
            topVC.alertError(with: .ChangeSingleParticipantNameFailed, dismiss: false)
        }
    }
}
