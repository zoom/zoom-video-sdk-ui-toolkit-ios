//
//  UIToolkitViewModel.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import ZoomVideoSDK
import UIKit

protocol UIToolkitViewModelDelegate: AnyObject {
    func updatedActiveSpeaker(isMyself: Bool)
}

class UIToolkitViewModel {
    
    private let sdkInstance: ZoomVideoSDK!
    private var localUser: ZoomVideoSDKUser!
    private var activeSpeakerAudioExist = false
    private var activeSpeaker: ZoomVideoSDKUser! {
        didSet {
            if activeSpeakerGalleryList.count > 0 {
                activeSpeakerGalleryList[0] = activeSpeaker
                delegate?.updatedActiveSpeaker(isMyself: isActiveSpeakerMyself())
            }
        }
    }
    private var activeSharer: ZoomVideoSDKUser?
    
    // The activeSpeakerGalleryList list is used to populate the collection view used to show active speaker and gallery view
    // Therefore it contains both local user and remote users.
    // The counter 0 is used for active speaker collection view cell while the remaining are for local and remote users' gallery view
    private var activeSpeakerGalleryList: [ZoomVideoSDKUser] = []
    
    weak var delegate: UIToolkitViewModelDelegate?
    
    private var domain = "zoom.us"
    
    // Initialization
    
    public init() {
        sdkInstance = ZoomVideoSDK.shareInstance()
    }
    
    public func setup(with inputSessionContext: SessionContext, inputInitParams: InitParams? = nil) {
        guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
        if inputSessionContext.jwt.isEmpty {
            ErrorManager.shared().getDelegate()?.onError(.EmptySessionToken)
            topVC.alertError(with: .EmptySessionToken, dismiss: true)
            return
        }
        if inputSessionContext.sessionName.isEmpty {
            ErrorManager.shared().getDelegate()?.onError(.EmptySessionName)
            topVC.alertError(with: .EmptySessionName, dismiss: true)
            return
        }
        if inputSessionContext.username.isEmpty {
            ErrorManager.shared().getDelegate()?.onError(.EmptyUsername)
            topVC.alertError(with: .EmptyUsername, dismiss: true)
            return
        }
        
        let initParams = ZoomVideoSDKInitParams()
        initParams.domain = domain
        initParams.enableLog = true
        
        // revise above parameters and set them here if we expose more params in the future
        initParams.appGroupId = inputInitParams?.appGroupId
        
        let sdkInitReturnStatus = ZoomVideoSDK.shareInstance()?.initialize(initParams)
        
        switch sdkInitReturnStatus {
        case .Errors_Success:
            print("Zoom UI Kit initialized successfully")
            
            let sessionContext = ZoomVideoSDKSessionContext()
            
            sessionContext.token = inputSessionContext.jwt
            sessionContext.sessionName = inputSessionContext.sessionName
            sessionContext.userName = inputSessionContext.username
            let videoOption = ZoomVideoSDKVideoOptions()
            videoOption.localVideoOn = false
            sessionContext.videoOption = videoOption
            sessionContext.audioOption?.connect = false
            
            if let password = inputSessionContext.sessionPassword {
                sessionContext.sessionPassword = password
            }
            
            ZoomVideoSDK.shareInstance()?.joinSession(sessionContext)
            print("Connecting user \(inputSessionContext.username) to session \(inputSessionContext.sessionName)...")
        default:
            if let error = sdkInitReturnStatus {
                print("Zoom UI Kit failed to initialize with error: \(error)")
            }
        }
    }
    
    public func getInitialData() {
        guard let myself = sdkInstance.getSession()?.getMySelf() else { return }
        localUser = myself
        activeSpeaker = localUser
        activeSpeakerGalleryList.append(myself) // Index 0 is for active speaker view
        activeSpeakerGalleryList.append(myself) // Index 1 is for gallery view
        
        /* Note!!
         getRemoteUsers here will always return empty even though there exist remote users since the getInitialData method is called after the onJoinSessionDelegate.
         So instead of that, we will have to rely on onUserJoin instead.
         
        guard let newRemoteUsersList = sdkInstance?.getSession()?.getRemoteUsers() else { return }
        remoteUserList.removeAll()
        remoteUserList = newRemoteUsersList
         */
    }
    
    // Session Title
    
    public func getSessionTitle() -> String {
        return sdkInstance.getSession()?.getName()?.uppercased() ?? "No Title"
    }
    
    // Page Control
    
    public func getUpdatedPageControlPage() -> Int {
        // -1 is because now local user is repeated twice for active speaker view and gallery view.
        if activeSpeakerGalleryList.count == 2 {
            return 1
        } else {
            let result = ceil(Double(activeSpeakerGalleryList.count + 3) / 4)
            return Int(result)
        }
    }
    
    public func shouldShowPageControl() -> Bool {
        return getUpdatedPageControlPage() != 1
    }
    
    public func getUserPage(with index: Int) -> Int {
        let result = ceil(Double(index) / 4)
        return Int(result)
    }
    
    // Local User
    
    public func getLocalUser() -> ZoomVideoSDKUser {
        return localUser
    }
    
    public func getLocalUserIsHost() -> Bool {
        if localUser == nil {
            return false
        }
        return localUser.isHost()
    }
    
    public func updateLocalUserCameraView(with view: UIView) {
        guard let localUserVideoCanvas = localUser.getVideoCanvas(), let localUserVideoIsOn = localUserVideoCanvas.videoStatus()?.on else { return }
        if localUserVideoIsOn {
            sdkInstance.getVideoHelper()?.rotateMyVideo(UIDevice.current.orientation)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch UIDevice.current.orientation {
                case .landscapeLeft, .landscapeRight:
                    localUserVideoCanvas.subscribe(with: view, aspectMode: .letterBox, andResolution: ._Auto)
                default:
                    localUserVideoCanvas.subscribe(with: view, aspectMode: .panAndScan, andResolution: ._Auto)
                }
            }
        } else {
            localUserVideoCanvas.unSubscribe(with: view)
        }
    }
    
    // Active Speaker
    
    public func getActiveSpeakerGalleryCount() -> Int {
        return activeSpeakerGalleryList.count
    }
    
    public func getActiveSpeakerGalleryCountForCollectionView() -> Int {
        let result = ceil(Double(activeSpeakerGalleryList.count - 1) / 4) * 4 + 1
        return Int(result)
    }
    
    public func isActiveSpeakerAudioExist() -> Bool {
        return activeSpeakerAudioExist
    }
    
    public func getActiveSpeaker() -> ZoomVideoSDKUser {
        return activeSpeaker
    }
    
    public func getActiveSharer() -> ZoomVideoSDKUser? {
        return activeSharer
    }
    
    public func isActiveSpeakerMyself() -> Bool {
        guard let myself = sdkInstance.getSession()?.getMySelf() else { return false }
        return myself == activeSpeaker
    }
    
    public func setActiveSpeaker(with user: ZoomVideoSDKUser) {
        activeSpeakerAudioExist = true
        activeSpeaker = user
    }
    
    public func setActiveSharer(with user: ZoomVideoSDKUser) {
        activeSharer = user
        setActiveSpeaker(with: user)
    }
    
    // User Management
    
    public func addRemoteUserList(with user: ZoomVideoSDKUser) -> Int {
        activeSpeakerGalleryList.append(user)
        if !activeSpeakerAudioExist {
            activeSpeaker = user
        }
        return activeSpeakerGalleryList.count - 1
    }
    
    public func removeRemoteUserList(with user: ZoomVideoSDKUser) -> Int? {
        guard var index = activeSpeakerGalleryList.lastIndex(of: user), let myselfIndex = activeSpeakerGalleryList.firstIndex(of: localUser) else { return nil }
        activeSpeakerGalleryList.remove(at: index)
        if activeSpeakerGalleryList.count == 2 {
            activeSpeaker = localUser
            index = myselfIndex
        } else if user == activeSpeaker {
            activeSpeaker = activeSpeakerGalleryList.last
            index = activeSpeakerGalleryList.count - 1
        }
        return index
    }
    
    public func getTotalParticipants() -> String {
        return String(activeSpeakerGalleryList.count - 1)
    }
    
    public func isOnlyLocalUserLeft() -> Bool {
        return !activeSpeakerGalleryList.contains(where: { $0 != localUser })
    }
    
    public func updateUser(with user: ZoomVideoSDKUser) {
        guard let index = activeSpeakerGalleryList.firstIndex(of: user) else { return }
        activeSpeakerGalleryList[index] = user
    }
    
    public func getUser(at index: Int) -> ZoomVideoSDKUser? {
        guard index < activeSpeakerGalleryList.count else { return nil }
        return activeSpeakerGalleryList[index]
    }
    
    public func getUserIndexPosition(with user: ZoomVideoSDKUser) -> Int? {
        guard let index = activeSpeakerGalleryList.firstIndex(of: user) else { return nil }
        return index
    }
    
    public func getUserIndex(with user: ZoomVideoSDKUser) -> [IndexPath]? {
        var indexPathList: [IndexPath] = []
        
        // Check if user is active speaker and return the index
        if user == activeSpeakerGalleryList[0] {
            indexPathList.append(IndexPath(item: 0, section: 0))
        }
        
        // Get the user's gallery view Index
        guard let index = activeSpeakerGalleryList.lastIndex(of: user) else { return nil }
        indexPathList.append(IndexPath(item: index, section: 0))
        
        return indexPathList
    }
    
    public func updateActiveSpeakerGalleryCameraView(with cell: ActiveSpeakerGalleryCollectionViewCell, at index: Int) {
        guard index < activeSpeakerGalleryList.count else { return }
        let currentUser = activeSpeakerGalleryList[index]
        guard let currentUserVideoCanvas = currentUser.getVideoCanvas(), let currentUserVideoIsOn = currentUserVideoCanvas.videoStatus()?.on else { return }
        
        cell.showDefaultAvatar(bool: !currentUserVideoIsOn)
        if currentUserVideoIsOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch UIDevice.current.orientation {
                case .landscapeLeft, .landscapeRight:
                    currentUserVideoCanvas.subscribe(with: cell.speakerView, aspectMode: .letterBox, andResolution: ._Auto)
                default:
                    currentUserVideoCanvas.subscribe(with: cell.speakerView, aspectMode: .panAndScan, andResolution: ._Auto)
                }
            }
        } else {
            currentUserVideoCanvas.unSubscribe(with: cell.speakerView)
            cell.setDefaultAvatarTitle(text: currentUser.getName()?.getDefaultName ?? "No Name", fontSize: index == 0 ? 64 : 48)
        }
        
        guard let audioIsMuted = currentUser.audioStatus()?.isMuted else { return }
        cell.micImageView.isHidden = !audioIsMuted
        cell.nameLabel.text = currentUser.getName()
    }
    
    public func updateActiveSharerGalleryCameraView(with cell: ActiveSpeakerGalleryCollectionViewCell, at index: Int) {
        guard index < activeSpeakerGalleryList.count else { return }
        let currentUser = activeSpeakerGalleryList[index]
        guard let currentUserShareCanvas = currentUser.getShareCanvas(), let currentUserShareStatus = currentUserShareCanvas.shareStatus()?.sharingStatus else { return }
        
        switch currentUserShareStatus {
        case .start, .resume:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch UIDevice.current.orientation {
                case .landscapeLeft, .landscapeRight:
                    currentUserShareCanvas.subscribe(with: cell.speakerView, aspectMode: .letterBox, andResolution: ._Auto)
                default:
                    currentUserShareCanvas.subscribe(with: cell.speakerView, aspectMode: .panAndScan, andResolution: ._Auto)
                }
            }
        default:
            currentUserShareCanvas.unSubscribe(with: cell.speakerView)
            activeSharer = nil
            setActiveSpeaker(with: activeSpeaker)
        }
    }
    
    public func isActiveSpeakerGalleryCameraOn(index: Int) -> Bool {
        return activeSpeakerGalleryList[index].getVideoCanvas()?.videoStatus()?.on ?? false
    }
    
    public func getActiveSpeakerGalleryName(index: Int) -> String {
        guard index < activeSpeakerGalleryList.count else { return "Out of index" }
        var role = ""
        if activeSpeakerGalleryList[index].isHost() {
            role = "(Host) "
        } else if activeSpeakerGalleryList[index].isManager() {
            role = "(Manager) "
        }
        return activeSpeakerGalleryList[index].getName() ?? "No name"
    }
    
}
