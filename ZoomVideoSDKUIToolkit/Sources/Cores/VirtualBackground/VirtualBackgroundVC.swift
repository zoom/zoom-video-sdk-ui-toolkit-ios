//
//  VirtualBackgroundVC.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit
import ZoomVideoSDK

class VirtualBackgroundVC: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var localUserPreview: UIView!
    @IBOutlet weak var localUserPreviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toggleCameraBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionCollectionView: UICollectionView!
    
    private let cellReuseIdentifier = "VBCollectionViewCell"
    private let viewModel: VirtualBackgroundViewModel!
    
    private var orientationChanged = false
    
    public init() {
        viewModel = VirtualBackgroundViewModel()
        super.init(
            nibName: String(describing: VirtualBackgroundVC.self),
            bundle: Bundle(for: VirtualBackgroundVC.self)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        onOrientationChange()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChanged = true
        
        coordinator.animate { _ in
            self.onOrientationChange()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let selectedIndexPath = IndexPath(row: viewModel.getPreSelectedVirtualBackgroundIndex(), section: 0)
        selectionCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
        
        showCameraVisibilityNoticeToast()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let helper = ZoomVideoSDK.shareInstance()?.getVideoHelper() else { return }
        helper.stopVideoCanvasPreview(localUserPreview)
    }

    private func setupUI() {
        setupNavBar()
        setupPreview()
        toggleCameraBtn.setTitle("", for: .normal)
        toggleCameraBtn.setImage(UIImage(named: "Camera", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
        toggleCameraBtn.tintColor = UIColor(red: 0, green: 0.32, blue: 0.85, alpha: 1)
        toggleCameraBtn.backgroundColor = .white
        toggleCameraBtn.layer.cornerRadius = toggleCameraBtn.frame.width / 2
        setupSelectionCollectionView()
    }
    
    private func setupNavBar() {
        let navItem = UINavigationItem(title: "Background")
        
        let crossBtn = UIButton(type: .custom)
        crossBtn.setImage(UIImage(named: "ChevronLeft", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
        crossBtn.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        crossBtn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: crossBtn)
        navItem.leftBarButtonItem = menuBarItem
        navItem.titleView?.tintColor = .black
        
        navBar.items = [navItem]
        navBar.barTintColor = .white
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    private func setupPreview() {
        localUserPreview.layer.cornerRadius = 8
        localUserPreview.clipsToBounds = true
        guard let helper = ZoomVideoSDK.shareInstance()?.getVideoHelper() else { return }
        helper.rotateMyVideo(UIDevice.current.orientation)
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            helper.startVideoCanvasPreview(localUserPreview, andAspectMode: .letterBox)
        default:
            helper.startVideoCanvasPreview(localUserPreview, andAspectMode: .panAndScan)
        }
    }
    
    private func onOrientationChange() {
        var newLocalUserPreviewHeightConstraint: NSLayoutConstraint
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            newLocalUserPreviewHeightConstraint = localUserPreviewHeightConstraint.constraintWithMultiplier(0.7)
        default:
            newLocalUserPreviewHeightConstraint = localUserPreviewHeightConstraint.constraintWithMultiplier(0.52)
        }
        localUserPreviewHeightConstraint.isActive = false
        localUserPreviewHeightConstraint = newLocalUserPreviewHeightConstraint
        localUserPreviewHeightConstraint.isActive = true
        
        if orientationChanged {
            view.layoutIfNeeded()
        }
        setupPreview()
        selectionCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupSelectionCollectionView() {
        selectionCollectionView.dataSource = self
        selectionCollectionView.delegate = self
        selectionCollectionView.isPagingEnabled = true
        selectionCollectionView.allowsMultipleSelection = false
        selectionCollectionView.backgroundColor = .white
        
        selectionCollectionView.register(UINib(nibName: cellReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: cellReuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        selectionCollectionView.collectionViewLayout = layout
        selectionCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func showCameraVisibilityNoticeToast() {
        let customAlertUI = CustomAlertBox()
        if !viewModel.isCameraOn() {
            customAlertUI.setButton(title: "Camera is off.", description: "You will need to turn on your camera to select a virtual background. By turning on your camera now, others will also be able to see you in the gallery view.")
            customAlertUI.delegate = self
        } else {
            customAlertUI.setButton(title: "Note", description: "Others will also be able to see your selection while you select the virtual background you want here.")
        }
        view.addSubview(customAlertUI)
        customAlertUI.fitLayoutTo(view: view)
        customAlertUI.present()
    }
    
    @objc private func closeVC() {
        guard let topVC = UIApplication.topViewController() else { return }
        topVC.dismissDetail()
    }
    
    @IBAction func onClickToggleCameraBtn(_ sender: UIButton) {
        guard let helper = ZoomVideoSDK.shareInstance()?.getVideoHelper() else { return }
        viewModel.setPreSelectedVirtualBackgroundIndex()
        DispatchQueue.global(qos: .background).async {
            helper.switchCamera()
        }
    }

}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension VirtualBackgroundVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getTotalVirtualBackgroundCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = selectionCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? VBCollectionViewCell else { return UICollectionViewCell() }
        
        cell.layer.cornerRadius = 8
        cell.backgroundColor = .white
        cell.setCell(image: viewModel.getImagePath(from: indexPath.row))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            return CGSize(width: (selectionCollectionView.frame.width - 16 * 4) / 5 , height: selectionCollectionView.frame.height)
        default:
            return CGSize(width: (selectionCollectionView.frame.width - 16 * 4) / 5 , height: (selectionCollectionView.frame.height - 16 * 3) / 4)
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectionCollectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ selectionCollectionView.deselectItem(at: $0, animated: false) })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectCurrentVB(at: indexPath.row)
    }
}

// MARK: CustomAlertBoxDelegate

extension VirtualBackgroundVC: CustomAlertBoxDelegate {
    func onClickCancelBtn() {
        closeVC()
    }
    
    func onClickConfirmBtn() {
        viewModel.setPreSelectedVirtualBackgroundIndex()
        guard let helper = ZoomVideoSDK.shareInstance()?.getVideoHelper() else { return }
        DispatchQueue.global(qos: .background).async {
            let error = helper.startVideo()
            if error != .Errors_Success {
                ErrorManager.shared().getDelegate()?.onError(.StartCameraFailed)
            }
        }
    }
}
