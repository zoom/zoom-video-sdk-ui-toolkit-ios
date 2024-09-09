//
//  MoreOptionManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import UIKit
import ZoomVideoSDK
import AVFoundation
import AVKit

enum MoreOptionEntryPoint {
    case MicAndAudio
    case Chat
    case VirtualBackground
    case CloudRecording
    case Settings
    
    var moreOption: (MoreOption) {
        switch self {
        case .MicAndAudio:
            return MoreOption(title: "Audio")
        case .Chat:
            return MoreOption(title: "Chat")
        case .VirtualBackground:
            return MoreOption(title: "Virtual Background")
        case .CloudRecording:
            return MoreOption(title: "Cloud Recording")
        case .Settings:
            return MoreOption(title: "Settings")
        }
    }
}

struct ParticipantMenu {
    let userSetting: UserSetting
    
    init(userSetting: UserSetting) {
        self.userSetting = userSetting
    }
}

class MoreOption {
    var title: String
    var isSelected: Bool = false
    var optionFunction: (() -> Void)?
    
    init(title: String, optionFunction: (() -> Void)? = nil) {
        self.title = title
        self.optionFunction = optionFunction
    }
}

class MoreOptionManager {
    
    // MARK: - Properties

    private static var moreOptionManager: MoreOptionManager = {
        let moreOptionManager = MoreOptionManager()
        
        // Any Other Configuration Below
        
        return moreOptionManager
    }()
    
    // MARK: - Variable
    
    var availableOption: [MoreOptionEntryPoint] = []
    let sheetView = CustomBottomSheetView()
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Accessors
    
    class func shared() -> MoreOptionManager {
        return moreOptionManager
    }
    
    func showAvailableOptionUI() {
        guard let vc = UIApplication.topViewController() else { return }
        sheetView.ctaStackView.removeAllArrangedSubviews()
        
        sheetView.ctaStackView.addArrangedSubview(getAudioMicButton())
        
        let availableFeature = FeatureManager.shared().getAvailableFeature()
        
        for feature in availableFeature {
            switch feature {
            case .Chat:
                sheetView.ctaStackView.addArrangedSubview(getChatButton())
            case .VirtualBackground:
                sheetView.ctaStackView.addArrangedSubview(getVirtualBackgroundButton())
            case .CloudRecording:
                sheetView.ctaStackView.addArrangedSubview(getCloudRecordingButton())
            case .ShareScreen:
                continue
            }
        }
        
        sheetView.ctaStackView.addArrangedSubview(getSettingsButton())
        
        vc.view.addSubview(sheetView)
        sheetView.fitLayoutTo(view: vc.view)
        sheetView.present()
    }
    
    func getMoreOptionEntryPoint(index: Int) -> MoreOptionEntryPoint {
        return availableOption[index]
    }
    
    func getMoreOption(index: Int) -> MoreOption {
        return availableOption[index].moreOption
    }
    
    func isLocalUserHostOrManager() -> Bool {
        guard let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return false }
        return myself.isHost() || myself.isManager()
    }
    
    func isLocalUserHost() -> Bool {
        guard let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return false }
        return myself.isHost()
    }
    
    func isLocalUserManager() -> Bool {
        guard let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() else { return false }
        return myself.isManager()
    }
    
    // MARK: Mic and Audio related
    
    private func getAudioMicButton() -> CustomBottomSheetCTAView {
        let ctaView = CustomBottomSheetCTAView()
        ctaView.setButton(image: "Phone", title: "Audio", action: showAvailableMicAndAudioOption)
        return ctaView
    }
    
    func showAvailableMicAndAudioOption() {
        sheetView.removeFromSuperview()
        guard let topVC = UIApplication.topViewController() else { return }
        
        // Add routePickerView and automatically send action to display AirPlay view
        let routePickerView = AVRoutePickerView()
        topVC.view.addSubview(routePickerView)
        
        if let routePickerButton = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton {
            routePickerButton.sendActions(for: .touchUpInside)
        }
        
        // Remove routePickerView once AirPlay view is displayed.
        routePickerView.removeFromSuperview()
    }
    
    // MARK: Chat related
    
    private func getChatButton() -> CustomBottomSheetCTAView {
        let ctaView = CustomBottomSheetCTAView()
        ctaView.setButton(image: "Chat-Border", title: "Chat", action: showChatMenu)
        let unreadMessageCount = ChatManager.shared().getUnreadMessageCount()
        if unreadMessageCount > 0 {
            ctaView.setupBadgeUI(hidden: false, with: "\(unreadMessageCount)")
        } else {
            ctaView.setupBadgeUI(hidden: true)
        }
        return ctaView
    }
    
    func showChatMenu() {
        sheetView.removeFromSuperview()
        guard let topVC = UIApplication.topViewController() else { return }
        let chatTableVC = ChatVC()
        chatTableVC.modalPresentationStyle = .custom
        topVC.presentDetail(chatTableVC)
    }
    
    // MARK: Virtual Background related
    
    private func getVirtualBackgroundButton() -> CustomBottomSheetCTAView {
        let ctaView = CustomBottomSheetCTAView()
        ctaView.setButton(image: "VirtualBackground", title: "Virtual Background", action: showVirtualBackgroundMenu)
        return ctaView
    }
    
    func showVirtualBackgroundMenu() {
        sheetView.removeFromSuperview()
        guard let topVC = UIApplication.topViewController() else { return }
        let vbVC = VirtualBackgroundVC()
        vbVC.modalPresentationStyle = .custom
        topVC.presentDetail(vbVC)
    }
    
    // MARK: Cloud Recording related
    
    private func getCloudRecordingButton() -> CustomBottomSheetCTAView {
        let ctaView = CustomBottomSheetCTAView()
        ctaView.setButton(image: "Record", title: "Cloud Recording", action: showCloudRecordingMenu)
        return ctaView
    }
    
    func showCloudRecordingMenu() {
        sheetView.removeFromSuperview()
    }
    
    // MARK: Settings related
    
    private func getSettingsButton() -> CustomBottomSheetCTAView {
        let ctaView = CustomBottomSheetCTAView()
        ctaView.setButton(image: "Setting", title: "Settings", action: showSettingsMenu)
        return ctaView
    }
    
    func showSettingsMenu() {
        sheetView.removeFromSuperview()
        
        guard let topVC = UIApplication.topViewController() else { return }
        let settingsVC = SettingsVC()
        settingsVC.modalPresentationStyle = .custom
        topVC.presentDetail(settingsVC)
    }
    
    func getLocalUserSettings() -> [LocalUserSetting] {
        var settings: [LocalUserSetting] = [.Personal]
        if UserManager.shared().isLocalUserHostOrManager() {
            settings.append(.Session)
        }
        return settings
    }

    func changeName(user: ZoomVideoSDKUser, with newName: String) -> Bool {
        guard let userHelper = ZoomVideoSDK.shareInstance()?.getUserHelper() else { return false }
        let success = userHelper.changeName(newName, with: user)
        if !success {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return false }
            ErrorManager.shared().getDelegate()?.onError(.ChangeLocalUserNameFailed)
            topVC.alertError(with: .ChangeLocalUserNameFailed, dismiss: false)
        }
        return success
    }
    
    // MARK: Chat Privilege related

    func getChatSettings() -> ZoomVideoSDKChatPrivilegeType? {
        if let currentChatPrivilege = ZoomVideoSDK.shareInstance()?.getChatHelper()?.getChatPrivilege(), (currentChatPrivilege == .everyone_Publicly_And_Privately || currentChatPrivilege == .no_One) {
            return currentChatPrivilege
        } else {
            return nil
        }
    }

    func isChatAllowed() -> Bool {
        let currentChatPrivilege = getChatSettings()
        switch currentChatPrivilege {
        case .everyone_Publicly_And_Privately:
            return true
        case .no_One:
            return false
        default:
            return false
        }
    }

    func changeChatPrivilege() -> Bool {
        guard let chatHelper = ZoomVideoSDK.shareInstance()?.getChatHelper(), let currentChatPrivilege = getChatSettings() else { return false }
        if currentChatPrivilege == .no_One {
            let result = chatHelper.change(.everyone_Publicly_And_Privately)
            if result != .Errors_Success {
                guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return false }
                ErrorManager.shared().getDelegate()?.onError(.EnableGroupAndPrivateChatFailed)
                topVC.alertError(with: .EnableGroupAndPrivateChatFailed, dismiss: false)
            } else {
                return true
            }
        } else if currentChatPrivilege == .everyone_Publicly_And_Privately {
            let result = chatHelper.change(.no_One)
            if result != .Errors_Success {
                guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return true }
                ErrorManager.shared().getDelegate()?.onError(.DisableGroupAndPrivateChatFailed)
                topVC.alertError(with: .DisableGroupAndPrivateChatFailed, dismiss: false)
            } else {
                return false
            }
        }

        return false
    }
    
    // MARK: Virtual Background
    
    public func isVirtualBackgroundEnabled() -> Bool {
        guard let vbHelper = ZoomVideoSDK.shareInstance()?.getVirtualBackgroundHelper() else { return false }
        return vbHelper.isSupportVirtualBackground()
    }
    
    // MARK: Share Screen
    
    private func showShareScreenInfo() {
        guard let userIsHost = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.isHost(), userIsHost, let currentIsShareLocked = ZoomVideoSDK.shareInstance()?.getShareHelper()?.isShareLocked() else { return }
        let alertTitle = "Share feature is \(currentIsShareLocked ? "Disabled" : "Enabled"): Tap to change."
//        alert.addAction(UIAlertAction(title: alertTitle, style: .default, handler: { _ in
//            // TODO: Add Share Sceen Feature
//            // Currently lockShare will give 2001 which indicates that there are missing module and in this case it's the ShareScreen module
//            ZoomVideoSDK.shareInstance()?.getShareHelper().lockShare(!currentIsShareLocked)
//        }))
    }
}
