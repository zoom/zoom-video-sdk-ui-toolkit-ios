//
//  VirtualBackgroundViewModel.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import ZoomVideoSDK

class VirtualBackgroundViewModel {
    
    private var vbHelper: ZoomVideoSDKVirtualBackgroundHelper!
    private var currentSelectedVB: ZoomVideoSDKVirtualBackgroundItem?
    
    public init() {
        // Note: Be default VSDK Virtual Background only comes with none or blurred. For UI toolkit we are providing one more alternative hence we add that in during init.
        guard let helper = ZoomVideoSDK.shareInstance()?.getVirtualBackgroundHelper(), let itemList =  helper.getVirtualBackgroundItemList() else { return }
        vbHelper = helper
        if itemList.count == 2 {
            helper.addVirtualBackgroundItem(UIImage(named: "VB-Grass", in: Bundle(for: type(of: self)), compatibleWith: .none))
        }
    }
    
    public func isCameraOn() -> Bool {
        return UserManager.shared().getLocalUser()?.getVideoCanvas()?.videoStatus()?.on ?? false
    }
    
    public func getTotalVirtualBackgroundCount() -> Int {
        return vbHelper.getVirtualBackgroundItemList()?.count ?? 0
    }
    
    public func getImagePath(from index: Int) -> String {
        if index == 0 {
            return "VB-None"
        } else if index == 1 {
            return "VB-Blurred"
        } else if index == 2 {
            return "VB-Grass"
        } 
        
        return vbHelper.getVirtualBackgroundItemList()?[index].imageFilePath ?? ""
    }
    
    public func selectCurrentVB(at index: Int) {
        guard let itemList =  vbHelper.getVirtualBackgroundItemList() else { return }
        let result = vbHelper.setVirtualBackgroundItem(itemList[index])
        if result != .Errors_Success {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.ChangeVirtualBackgroundFailed)
            topVC.alertError(with: .ChangeVirtualBackgroundFailed, dismiss: false)
        } else {
            currentSelectedVB = itemList[index]
        }
    }
    
    public func getPreSelectedVirtualBackgroundIndex() -> Int {
        guard let itemList =  vbHelper.getVirtualBackgroundItemList(), let selectedBackground = vbHelper.getSelectedVirtualBackgroundItem() else {
            return 0
        }
        let index = itemList.firstIndex(where: { $0 == selectedBackground }) ?? 0
        currentSelectedVB = itemList[index]
        return index
    }
    
    public func setPreSelectedVirtualBackgroundIndex() {
        guard let selectedVB = currentSelectedVB else { return }
        let result = vbHelper.setVirtualBackgroundItem(selectedVB)
        if result != .Errors_Success {
            guard let topVC = UIApplication.topViewController() as? UIToolkitVC else { return }
            ErrorManager.shared().getDelegate()?.onError(.ChangeVirtualBackgroundFailed)
            topVC.alertError(with: .ChangeVirtualBackgroundFailed, dismiss: false)
        }
    }
}
