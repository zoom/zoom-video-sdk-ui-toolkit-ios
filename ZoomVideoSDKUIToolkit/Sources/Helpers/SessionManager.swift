//
//  SessionManager.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit
import ZoomVideoSDK

class SessionManager {
    
    // MARK: - Properties

    private static var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        
        // Any Other Configuration Below
        
        return sessionManager
    }()
    
    // MARK: - Variable
    var loader: Loader?
    var selfLeave: Bool = false
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Accessors
    
    class func shared() -> SessionManager {
        return sessionManager
    }
    
    public func resetSession() {
        selfLeave = false
    }
    
    public func presentLeaveMenu() {
        guard let vc = UIApplication.topViewController() else { return }
        
        let sheetView = CustomBottomSheetView()
        sheetView.ctaStackView.addArrangedSubview(getLeaveButton())
        
        if let hostButton = getHostEndMeetingButton() {
            sheetView.ctaStackView.addArrangedSubview(hostButton)
        }
        
        vc.view.addSubview(sheetView)
        sheetView.fitLayoutTo(view: vc.view)
        sheetView.present()
    }
    
    private func getLeaveButton() -> CustomBottomSheetCTAView {
        let ctaView = CustomBottomSheetCTAView()
        
        if let userIsHost = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.isHost(), userIsHost, ZoomVideoSDK.shareInstance()?.getSession()?.getRemoteUsers()?.count ?? 0 > 0 {
            ctaView.setButton(title: "Leave session", action: reassignAndLeave)
        } else {
            ctaView.setButton(title: "Leave session", action: leaveSession)
        }
            
        return ctaView
    }
    
    private func getHostEndMeetingButton() -> CustomBottomSheetCTAView? {
        guard let isHost = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.isHost(), isHost else { return nil }
        let ctaView = CustomBottomSheetCTAView()
        ctaView.setButton(title: "End session for all", textColor: .red, action: showEndSessionUI)
        return ctaView
    }
    
    private func leaveSession() {
        guard let topVC = UIApplication.topViewController() else { return }
        loader = Loader(forView: topVC.view)
        loader?.showLoading(withText: "Leaving session...")
        if let error = ZoomVideoSDK.shareInstance()?.leaveSession(false) {
            // Note: Errors_Success are handled by Zoom Delegate onSessionLeave
            selfLeave = true
            if error != .Errors_Success {
                self.loader?.hideLoading()
                ErrorManager.shared().getDelegate()?.onError(.LeaveSessionFailed)
                topVC.alertError(with: .LeaveSessionFailed, dismiss: false)
            }
        }
    }
    
    private func reassignAndLeave() {
        guard let topVC = UIApplication.topViewController() else { return }
        let assignHostVC = ParticipantsVC(entryPoint: .LeaveAndReassignHost)
        assignHostVC.setSuccessAction(with: leaveSession)
        assignHostVC.modalPresentationStyle = .custom
        topVC.presentDetail(assignHostVC)
    }
    
    private func showEndSessionUI() {
        guard let vc = UIApplication.topViewController() else { return }
        let alertBox = CustomAlertBox()
        alertBox.setButton(title: "End session for all", description: "Are you sure you want to end the session for all participants?")
        alertBox.delegate = self
        vc.view.addSubview(alertBox)
        alertBox.fitLayoutTo(view: vc.view)
        alertBox.present()
    }
    
    private func endSession() {
        guard let topVC = UIApplication.topViewController() else { return }
        loader = Loader(forView: topVC.view)
        loader?.showLoading(withText: "Leaving session...")
        if let error = ZoomVideoSDK.shareInstance()?.leaveSession(true) {
            // Note: Errors_Success are handled by Zoom Delegate onSessionLeave
            selfLeave = true
            if error != .Errors_Success {
                self.loader?.hideLoading()
                ErrorManager.shared().getDelegate()?.onError(.EndSessionFailed)
                topVC.alertError(with: .EndSessionFailed, dismiss: false)
            }
        }
    }
}

extension SessionManager: CustomAlertBoxDelegate {
    // CustomAlertBox only used for Host to confirm end meeting
    func onClickConfirmBtn() {
        endSession()
    }
}
