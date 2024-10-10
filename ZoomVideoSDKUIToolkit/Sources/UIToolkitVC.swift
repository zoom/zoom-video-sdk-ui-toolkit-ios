//
//  UIToolkitVC.swift
//  ZoomVideoSDKUIToolKit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit
import ZoomVideoSDK
import ReplayKit

/// The UI toolkit view controller manages and shows the prebuilt video chat user interface.
public class UIToolkitVC: UIViewController {
    
    // MARK: IBOutlet and variables
    @IBOutlet weak var topNavBar: UIView!
    @IBOutlet weak var changeCameraBtn: UIButton!
    @IBOutlet weak var sessionTitleLabel: UILabel!
    @IBOutlet weak var endSessionBtn: UIButton!
    
    @IBOutlet weak var activeSpeakerGalleryCollectionView: UICollectionView!
    @IBOutlet weak var activeSpeakerGalleryCollectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeSpeakerGalleryCollectionViewBtmConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var localUserView: UIView!
    @IBOutlet weak var localUserViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var localUserViewAspectConstraint: NSLayoutConstraint!
    @IBOutlet weak var localUserViewLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var localUserLabelHolderView: UIView!
    @IBOutlet weak var localUserLabel: UILabel!
    
    @IBOutlet weak var bottomNavBar: UIView!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var shareScreenBtn: UIButton!
    @IBOutlet weak var participantBtn: BadgeButton!
    @IBOutlet weak var moreBtn: BadgeButton!
    
    @IBOutlet weak var pageControlView: UIView!
    @IBOutlet weak var pageControlHolderView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var shareScreenView: UIView!
    @IBOutlet weak var stopSharingButton: UIButton!

    internal var inputSessionContext: SessionContext!
    internal var inputInitParams: InitParams?
    
    private var loader: Loader?
    
    /// The UIToolkitDelegate sends event notifications.
    @objc public weak var delegate: UIToolkitDelegate?
    
    // Idle Timer - For Showing/Hiding of Bottom Nav Bar
    var idleTimer = Timer()
    var maxIdleTime = 5.0 // secs
    
    // New active speaker and gallery view
    private var activeSpeakerGalleryCellReuseIdentifier = "ActiveSpeakerGalleryCollectionViewCell"
    private var activeSpeakerGalleryCellSpacing = 8
    
    // View Model
    var viewModel: UIToolkitViewModel!
    
    // MARK: Initialization
    
    public init(sessionContext: SessionContext, initParams: InitParams? = nil) {
        self.inputSessionContext = sessionContext
        self.inputInitParams = initParams
        super.init(nibName: "UIToolkitVC", bundle: Bundle(for: UIToolkitVC.self))
    }
    
    @objc public init(sessionContextObject: SessionContextObjC, initParamsObject: InitParamsObjC? = nil) {
        self.inputSessionContext = SessionContext(sessionContextObject: sessionContextObject)
        if let paramsObject = initParamsObject {
            self.inputInitParams = InitParams(initParamsObject: paramsObject)
        }
        super.init(nibName: "UIToolkitVC", bundle: Bundle(for: UIToolkitVC.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .unreadMessageRead, object: nil)
        NotificationCenter.default.removeObserver(self, name: .newMessageReceived, object: nil)
    }
    
    // MARK: View Controller Lifecycle
    
    @_documentation(visibility:private)
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // If inputInitParams.features is not given, the default is to set all features as available.
        if let features = inputInitParams?.features {
            FeatureManager.shared().setAvailableFeature(with: features)
        } else {
            FeatureManager.shared().setAllAvailableFeature()
        }
        
        setupUI()
        viewModel = UIToolkitViewModel()
        viewModel.delegate = self
        if let delegate = delegate {
            ErrorManager.shared().setDelegate(with: delegate)
        }
        setupNotifications()
    }
    
    @_documentation(visibility:private)
    public override func viewWillAppear(_ animated: Bool) {
        if PermissionManager.shared().checkIfMicAndCameraPermissionsGranted() {
            setupConnection()
        }
    }
    
    @_documentation(visibility:private)
    public override func viewDidLayoutSubviews() {
        micBtn.alignTextBelow()
        videoBtn.alignTextBelow()
        shareScreenBtn.alignTextBelow()
        participantBtn.alignTextBelow()
        moreBtn.alignTextBelow()
    }
    
    @_documentation(visibility:private)
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { _ in
            self.activeSpeakerGalleryCollectionView.collectionViewLayout.invalidateLayout()
            self.updateLocalUserVideoView()
            self.setupBottomButtonBar()
        }
    }
    
    @_documentation(visibility:private)
    public override func viewWillDisappear(_ animated: Bool) {
        delegate = nil
        viewModel.delegate = nil
        ChatManager.shared().delegate = nil
        ZoomVideoSDK.shareInstance()?.cleanup()
        super.viewWillDisappear(animated)
    }
    
    // MARK: Setup
    
    private func setupUI() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        loader = Loader(forView: self.view)
        loader?.showLoading(withText: "Connecting...")
        
        hideKeyboardWhenClickedAround()
        
        pageControlHolderView.layer.cornerRadius = pageControlHolderView.frame.width / 10
        pageControl.numberOfPages = 1
        pageControl.isUserInteractionEnabled = false
        
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
            pageControl.allowsContinuousInteraction = false
        }
        
        setupLocalUserView()
        setupActiveSpeakerGalleryView()
        
        setupTopNavBar()
    }
    
    private func setupNotifications() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMessageRead), name: .unreadMessageRead, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageReceived), name: .newMessageReceived, object: nil)
    }
    
    private func setupIdleTimerForNavBar() {
        topNavBar.isHidden = false
        bottomNavBar.isHidden = false
        idleTimer.invalidate()
        setupIdleTimerToHideNavBar()
        let resetTimerGesture = UITapGestureRecognizer(target: self, action: #selector(resetTimerAndShowTopBottomNavBar));
        resetTimerGesture.cancelsTouchesInView = false
        self.activeSpeakerGalleryCollectionView.isUserInteractionEnabled = true
        self.activeSpeakerGalleryCollectionView.addGestureRecognizer(resetTimerGesture)
    }
    
    @objc private func resetTimerAndShowTopBottomNavBar() {
        idleTimer.invalidate()
        
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            if topNavBar.isHidden && bottomNavBar.isHidden {
                setupIdleTimerToHideNavBar()
            }
            topNavBar.isHidden = !topNavBar.isHidden
            bottomNavBar.isHidden = !bottomNavBar.isHidden
        default:
            if bottomNavBar.isHidden {
                setupIdleTimerToHideNavBar()
            }
            bottomNavBar.isHidden = !bottomNavBar.isHidden
        }
        
    }
    
    private func setupIdleTimerToHideNavBar() {
        activeSpeakerGalleryCollectionViewTopConstraint.isActive = false
        activeSpeakerGalleryCollectionViewBtmConstraint.isActive = false
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            activeSpeakerGalleryCollectionViewTopConstraint = activeSpeakerGalleryCollectionView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor)
            activeSpeakerGalleryCollectionViewBtmConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: activeSpeakerGalleryCollectionView.bottomAnchor)
            idleTimer = Timer.scheduledTimer(timeInterval: maxIdleTime, target: self, selector: #selector(hideTopAndBottomNavBar), userInfo: nil, repeats: false)
            
            activeSpeakerGalleryCollectionViewTopConstraint.isActive = true
            activeSpeakerGalleryCollectionViewBtmConstraint.isActive = true
        default:
            activeSpeakerGalleryCollectionViewTopConstraint = activeSpeakerGalleryCollectionView.topAnchor.constraint(equalTo: topNavBar.bottomAnchor)
            activeSpeakerGalleryCollectionViewBtmConstraint = activeSpeakerGalleryCollectionView.bottomAnchor.constraint(equalTo: bottomNavBar.topAnchor)
            idleTimer = Timer.scheduledTimer(timeInterval: maxIdleTime, target: self, selector: #selector(hideBottomNavBar), userInfo: nil, repeats: false)
            
            activeSpeakerGalleryCollectionViewTopConstraint.isActive = true
            activeSpeakerGalleryCollectionViewBtmConstraint.isActive = true
        }
    }
    
    @objc private func hideBottomNavBar() {
        idleTimer.invalidate()
        bottomNavBar.isHidden = true
    }
    
    @objc private func hideTopAndBottomNavBar() {
        idleTimer.invalidate()
        topNavBar.isHidden = true
        bottomNavBar.isHidden = true
    }
    
    private func setupLocalUserView() {
        localUserView.backgroundColor = .white
        localUserView.clipsToBounds = true
        localUserView.layer.cornerRadius = 8
        reshapeLocalUserView()
        localUserView.isHidden = true
    }
    
    private func reshapeLocalUserView() {
        localUserLabelHolderView.layer.cornerRadius = localUserLabelHolderView.frame.width / 2
    }
    
    private func setupActiveSpeakerGalleryView() {
        activeSpeakerGalleryCollectionView.dataSource = self
        activeSpeakerGalleryCollectionView.delegate = self
        activeSpeakerGalleryCollectionView.register(UINib(nibName: activeSpeakerGalleryCellReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: activeSpeakerGalleryCellReuseIdentifier)
        activeSpeakerGalleryCollectionView.isPagingEnabled = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        activeSpeakerGalleryCollectionView.collectionViewLayout = layout
        activeSpeakerGalleryCollectionView.showsHorizontalScrollIndicator = false
        activeSpeakerGalleryCollectionView.isScrollEnabled = false
    }
    
    private func setupConnection() {
        viewModel.setup(with: inputSessionContext, inputInitParams: inputInitParams)
        ZoomVideoSDK.shareInstance()?.delegate = self
    }
    
    @objc private func onOrientationChange() {
        setupIdleTimerForNavBar()
        
        var newLocalUserViewWidthConstraint: NSLayoutConstraint
        var newLocalUserViewAspectConstraint: NSLayoutConstraint
        var newLocalUserViewLabelWidthConstraint: NSLayoutConstraint
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            pageControlView.backgroundColor = .clear
            topNavBar.backgroundColor = .init(white: 1, alpha: 0.75)
            bottomNavBar.backgroundColor = .init(white: 1, alpha: 0.75)
            newLocalUserViewWidthConstraint = localUserViewWidthConstraint.constraintWithMultiplier(0.185)
            newLocalUserViewAspectConstraint = localUserViewAspectConstraint.constraintWithMultiplier(1.5)
            newLocalUserViewLabelWidthConstraint = localUserViewLabelWidthConstraint.constraintWithMultiplier(0.5)
        default:
            pageControlView.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
            topNavBar.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
            bottomNavBar.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
            newLocalUserViewWidthConstraint = localUserViewWidthConstraint.constraintWithMultiplier(0.282)
            newLocalUserViewAspectConstraint = localUserViewAspectConstraint.constraintWithMultiplier(3/4)
            newLocalUserViewLabelWidthConstraint = localUserViewLabelWidthConstraint.constraintWithMultiplier(0.76)
        }
        localUserViewWidthConstraint.isActive = false
        localUserViewWidthConstraint = newLocalUserViewWidthConstraint
        localUserViewWidthConstraint.isActive = true
        localUserViewAspectConstraint.isActive = false
        localUserViewAspectConstraint = newLocalUserViewAspectConstraint
        localUserViewAspectConstraint.isActive = true
        localUserViewLabelWidthConstraint.isActive = false
        localUserViewLabelWidthConstraint = newLocalUserViewLabelWidthConstraint
        localUserViewLabelWidthConstraint.isActive = true
        
        activeSpeakerGalleryCollectionView.reloadData()
    }
    
    // MARK: IBAction
    
    @IBAction func onClickChangeCameraBtn(_ sender: Any) {
        if let videoHelper = ZoomVideoSDK.shareInstance()?.getVideoHelper() {
            videoHelper.switchCamera()
        }
    }
    
    @IBAction func onClickEndSessionBtn(_ sender: Any) {
        SessionManager.shared().presentLeaveMenu()
    }
    
    @IBAction func onClickMicBtn(_ sender: Any) {
        guard let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() else { return }
        micBtn.isUserInteractionEnabled = false
        
        if (ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.audioStatus()?.audioType == ZoomVideoSDKAudioType.none) {
            let error = audioHelper.startAudio()
            if error != .Errors_Success {
                
            }
        } else {
            if let isMuted = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.audioStatus()?.isMuted, let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
                
                var error: ZoomVideoSDKError
                
                if isMuted {
                    error = audioHelper.unmuteAudio(myself)
                } else {
                    error = audioHelper.muteAudio(myself)
                }
                
                if error != .Errors_Success {
                    if !isMuted {
                        delegate?.onError(.MuteMicFailed)
                        alertError(with: .MuteMicFailed, dismiss: false)
                    } else {
                        delegate?.onError(.UnmuteMicFailed)
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.micBtn.isUserInteractionEnabled = true
        }
        
    }
    
    @IBAction func onClickVideoBtn(_ sender: Any) {
        guard let videoHelper = ZoomVideoSDK.shareInstance()?.getVideoHelper(), let videoIsOn = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.getVideoCanvas()?.videoStatus()?.on else { return }
        videoBtn.isUserInteractionEnabled = false
        
        if videoIsOn {
            let error = videoHelper.stopVideo()
            if error != .Errors_Success {
                delegate?.onError(.StopCameraFailed)
                alertError(with: .StopCameraFailed, dismiss: false)
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                let error = videoHelper.startVideo()
                if error != .Errors_Success {
                    self.delegate?.onError(.StartCameraFailed)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.videoBtn.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func onClickShareScreenBtn(_ sender: Any) {
        if let isSomeoneSharing = ZoomVideoSDK.shareInstance()?.getShareHelper()?.isOtherSharing(), isSomeoneSharing == true {
            let alert = UIAlertController(title: "Screen sharing already in progress.", message: nil, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
                self.dismiss(animated: true)
            })
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }

        showShareScreenPicker()
    }
    
    @IBAction func onClickStopShareBtn(_ sender: Any) {
        showShareScreenPicker()
    }
    
    @IBAction func onClickParticipantBtn(_ sender: Any) {
        guard let topVC = UIApplication.topViewController() else { return }
        let assignHostVC = ParticipantsVC(entryPoint: .ShowInformation)
        assignHostVC.modalPresentationStyle = .custom
        topVC.presentDetail(assignHostVC)
    }
    
    @IBAction func onClickMoreBtn(_ sender: Any) {
        MoreOptionManager.shared().showAvailableOptionUI()
    }
    
    // MARK: Private Method
    
    private func setupTopNavBar() {
        /* Note!
         Have to manually set title with "" to override the default "button" from appearing even when design is set to nil.
         For more info: https://stackoverflow.com/questions/73458504/swift-uibutton-empty-in-storyboard-but-has-text-while-running
         */
        
        // Top Nav Bar is stack view, cannot simply use isHidden to hide changeCameraBtn
        changeCameraBtn.setTitle("", for: .normal)
        changeCameraBtn.isEnabled = FeatureManager.shared().checkIfFeatureIsAvailable(with: .Video)
        if FeatureManager.shared().checkIfFeatureIsAvailable(with: .Video) {
            let changeCameraImage = UIImage(named: "Camera", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate).resizedImage(Size: CGSize(width: 28, height: 28))
            changeCameraBtn.setImage(changeCameraImage, for: .normal)
            changeCameraBtn.imageView?.contentMode = .scaleAspectFit
            changeCameraBtn.tintColor = .black
        }
         
        endSessionBtn.setTitle("", for: .normal)
        endSessionBtn.layer.cornerRadius = 6
    }
    
    private func updateLocalUserVideoView() {
        viewModel.updateLocalUserCameraView(with: localUserView)
        localUserLabel.text = viewModel.getLocalUser().getName()?.getDefaultName
    }
    
    private func setupBottomButtonBar() {
        setupMicBtnUI()
        setupVideoBtnUI()
        setupShareScreenBtnUI()
        setupParticipantsBtnUI()
        setupMoreBtnUI()
    }
    
    private func setupMicBtnUI() {
        if FeatureManager.shared().checkIfFeatureIsAvailable(with: .Audio) {
            micBtn.isHidden = false
            micBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            var audioImageName = "Mic"
            
            if let isMuted = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.audioStatus()?.isMuted {
                audioImageName = isMuted ? "Mic-Disabled" : "Mic"
                micBtn.setTitle(isMuted ? "Unmute" : "Mute", for: .normal)
            }
            
            let audioUIImage = UIImage(named: audioImageName, in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
            
            micBtn.frame.size = CGSize(width: 56, height: 56)
            micBtn.setImage(audioUIImage, for: .normal)
        } else {
            micBtn.isHidden = true
        }
    }
    
    private func animateMicBtnUI() {
        let animateMicList = ["Mic-33", "Mic-66", "Mic-100", "Mic-66", "Mic-33"]
        
        for i in 0...animateMicList.count-1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * Double(i)) {
                if !(ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.audioStatus()?.isMuted ?? false) {
                    let audioUIImage = UIImage(named: animateMicList[i], in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysOriginal)
                    self.micBtn.setImage(audioUIImage, for: .normal)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20 * Double(animateMicList.count)) {
            if !(ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.audioStatus()?.isMuted ?? false) {
                let audioUIImage = UIImage(named: "Mic", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
                self.micBtn.setImage(audioUIImage, for: .normal)
            }
        }
    }
    
    private func setupVideoBtnUI() {
        if FeatureManager.shared().checkIfFeatureIsAvailable(with: .Video) {
            videoBtn.isHidden = false
            videoBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            var videoImageName = "Video"
            
            if let videoIsOn = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.getVideoCanvas()?.videoStatus()?.on {
                videoImageName = videoIsOn ?  "Video" : "Video-Disabled"
                videoBtn.setTitle(videoIsOn ? "Stop Video" : "Start Video", for: .normal)
            }
            
            let videoImageUIName = UIImage(named: videoImageName, in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
            
            videoBtn.frame.size = CGSize(width: 56, height: 56)
            videoBtn.setImage(videoImageUIName, for: .normal)
        } else {
            videoBtn.isHidden = true
        }
    }
    
    private func setupShareScreenBtnUI() {
        if FeatureManager.shared().checkIfFeatureIsAvailable(with: .ShareScreen) {
            shareScreenBtn.isHidden = false
            shareScreenBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            var screenShareImageName = "ShareScreen"
            
            let isSharing = (ZoomVideoSDK.shareInstance()?.getShareHelper()?.isSharingOut() ?? false || ZoomVideoSDK.shareInstance()?.getShareHelper()?.isScreenSharingOut() ?? false)
            
            screenShareImageName = isSharing ?  "ShareStop" : "ShareScreen"
            shareScreenBtn.setTitle(isSharing ? "Stop Share" : "Share", for: .normal)
            
            let shareScreenImageUIName = UIImage(named: screenShareImageName, in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
                .resizedImage(Size: CGSize(width: 28, height: 28))
            
            shareScreenBtn.imageView?.contentMode = .scaleAspectFit
            shareScreenBtn.frame.size = CGSize(width: 56, height: 56)
            shareScreenBtn.setImage(shareScreenImageUIName, for: .normal)

        } else {
            shareScreenBtn.isHidden = true
        }
    }
    
    private func setupParticipantsBtnUI() {
        if FeatureManager.shared().checkIfFeatureIsAvailable(with: .Users) {
            participantBtn.isHidden = false
            participantBtn.setTitle("Participants", for: .normal)
            participantBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            participantBtn.addBadgeToButton(badge: viewModel.getTotalParticipants())
        } else {
            participantBtn.isHidden = true
        }
    }
    
    private func showShareScreenPicker() {
        let broadcastPickerView = RPSystemBroadcastPickerView()
        broadcastPickerView.preferredExtension = inputInitParams?.appGroupId
        shareScreenBtn.addSubview(broadcastPickerView)
        
        for view in broadcastPickerView.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .allTouchEvents)
            }
        }
    }
    
    private func setupMoreBtnUI() {
        moreBtn.isHidden = !MoreOptionManager.shared().canShowMoreBtn()
        moreBtn.setTitle("More", for: .normal)
        moreBtn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
}

// MARK: ZoomVideoSDKDelegate

@_documentation(visibility:private)
extension UIToolkitVC: ZoomVideoSDKDelegate {
    @objc public func onError(_ ErrorType: ZoomVideoSDKError, detail details: Int) {
        switch ErrorType {
        case .Errors_Auth_Empty_Key_or_Secret:
            alertError(with: .EmptyKeyOrSecret, dismiss: true)
            delegate?.onError(.EmptyKeyOrSecret)
        case .Errors_Auth_Wrong_Key_or_Secret:
            alertError(with: .InvalidKeyOrSecret, dismiss: true)
            delegate?.onError(.InvalidKeyOrSecret)
        case .Errors_JoinSession_Token_NoSessionName:
            alertError(with: .TokenEmptySessionName, dismiss: true)
            delegate?.onError(.TokenEmptySessionName)
        case .Errors_JoinSession_Invalid_SessionName:
            alertError(with: .InvalidSessionName, dismiss: true)
            delegate?.onError(.InvalidSessionName)
        case .Errors_JoinSession_Invalid_Password:
            alertError(with: .WrongPassword, dismiss: true)
            delegate?.onError(.WrongPassword)
        case .Errors_JoinSession_Invalid_SessionToken:
            alertError(with: .InvalidSessionToken, dismiss: true)
            delegate?.onError(.InvalidSessionToken)
        case .Errors_Session_Need_Password:
            alertError(with: .MissingPassword, dismiss: true)
            delegate?.onError(.MissingPassword)
        case .Errors_JoinSession_SessionName_TooLong:
            alertError(with: .SessionNameTooLong, dismiss: true)
            delegate?.onError(.SessionNameTooLong)
        case .Errors_JoinSession_Token_MismatchedSessionName:
            alertError(with: .TokenMismatchedSessionName, dismiss: true)
            delegate?.onError(.TokenMismatchedSessionName)
        case .Errors_JoinSession_Token_UserIdentity_TooLong:
            alertError(with: .TokenUserIdentityTooLong, dismiss: true)
            delegate?.onError(.TokenUserIdentityTooLong)
        case .Errors_Session_Invalid_Param:
            alertError(with: .InvalidParam, dismiss: true)
            delegate?.onError(.InvalidParam)
        case .Errors_Session_Join_Failed:
            alertError(with: .JoinFailed, dismiss: true)
            delegate?.onError(.JoinFailed)
        default:
            break
        }
    }
    
    public func onSessionNeedPassword(_ completion: ((String?, Bool) -> ZoomVideoSDKError)? = nil) {
        let alert = UIAlertController(title: "Required password", message: "Enter session password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [] (_) in
            _ = completion!(nil, true)
        }))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            _ = completion!(textField?.text, false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func onHostAskUnmute() {
        showUnmuteRequestUI()
    }
    
    public func onSessionPasswordWrong(_ completion: ((String?, Bool) -> ZoomVideoSDKError)? = nil) {
        let alert = UIAlertController(title: "Wrong password", message: "Enter session password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { [] (_) in
            _ = completion!(nil, true)
        }))
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            _ = completion!(textField?.text, false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func onSessionJoin() {
        print("Successfully joined session: \(ZoomVideoSDK.shareInstance()?.getSession()?.getName() ?? "No Session Name")")
        SessionManager.shared().resetSession()
        
        if let audioHelper = ZoomVideoSDK.shareInstance()?.getAudioHelper() {
            if (ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.audioStatus()?.audioType == ZoomVideoSDKAudioType.none) {
                let error = audioHelper.startAudio()
                if error != .Errors_Success {
                    
                }
            }
        }
        
        /* Note!!
          The onJoinSession callback always return empty result for the getRemoteUsers method. Thus, we cannot get remote users here despite having remote user(s) and will have to rely on onUserJoin instead.
         */
        
        viewModel.getInitialData()
        activeSpeakerGalleryCollectionView.reloadData()
        
        loader?.hideLoading()
        
        ChatManager.shared().delegate = self
        
        sessionTitleLabel.text = viewModel.getSessionTitle()
        
        updateLocalUserVideoView()
        setupBottomButtonBar()
        
        delegate?.onViewLoaded()
    }
    
    public func onSessionLeave(_ reason: ZoomVideoSDKSessionLeaveReason) {
        if SessionManager.shared().selfLeave {
            print("Successfully leave session")
            self.delegate?.onViewDismissed()
            self.dismiss(animated: true)
        } else {
            // Host ended meeting or Host/Manager kicked
            // TODO: Think of how we can manage this instead of hard coding the classes
            if let vc = UIApplication.topViewController() {
                if vc.isKind(of: SettingsVC.self) || vc.isKind(of: ChatVC.self) || vc.isKind(of: ParticipantsVC.self){
                    self.dismissDetail()
                }
            }
            
            let alert = UIAlertController(title: "Host ended session.", message: nil, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Leave", style: .default, handler: {_ in
                print("Successfully leave session")
                self.delegate?.onViewDismissed()
                self.dismiss(animated: true)
            })
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
            
            if self.isAlertControlPresenting() {
                // This is to check if alert control is presented in the event that an error occurred then
                // it does not get self.dismiss under else clause immediately since self.dismiss is suppose to be for the UIToolkitVC and not AlertControl
                // Do nothing here - onError is handling this.
            }
        }
    }
    
    public func onUserAudioStatusChanged(_ helper: ZoomVideoSDKAudioHelper?, user userArray: [ZoomVideoSDKUser]?) {
        if let userArray = userArray {
            for user in userArray {
                if user == UserManager.shared().getLocalUser() {
                    setupMicBtnUI()
                    UserManager.shared().updateLocalUser(with: user)
                } else {
                    UserManager.shared().updateRemoteUser(with: user)
                }
                
                if let userIndexPathList = viewModel.getUserIndex(with: user), let userIsMuted = user.audioStatus()?.isMuted {
                    for currentIndex in userIndexPathList {
                        guard let cell = activeSpeakerGalleryCollectionView.cellForItem(at: currentIndex) as? ActiveSpeakerGalleryCollectionViewCell else { return }
                        viewModel.updateUser(with: user)
                        cell.micImageView.isHidden = !userIsMuted
                    }
                }
            }
        }
    }
    
    public func onUserVideoStatusChanged(_ helper: ZoomVideoSDKVideoHelper?, user userArray: [ZoomVideoSDKUser]?) {
        if let userArray = userArray {
            for user in userArray {
                if let userIndexPathList = viewModel.getUserIndex(with: user) {
                    for currentIndex in userIndexPathList {
                        if let cell = activeSpeakerGalleryCollectionView.cellForItem(at: currentIndex) as? ActiveSpeakerGalleryCollectionViewCell {
                            viewModel.updateUser(with: user)
                            viewModel.updateActiveSpeakerGalleryCameraView(with: cell, at: currentIndex.row)
                        }
                    }
                }
                
                if user == UserManager.shared().getLocalUser() {
                    setupVideoBtnUI()
                    updateLocalUserVideoView()
                    UserManager.shared().updateLocalUser(with: user)
                } else {
                    UserManager.shared().updateRemoteUser(with: user)
                }
            }
        }
    }
    
    public func onUserShareStatusChanged(_ helper: ZoomVideoSDKShareHelper?, user: ZoomVideoSDKUser?, status: ZoomVideoSDKReceiveSharingStatus) {
        if let user = user {
            guard user != UserManager.shared().getLocalUser() else {
                switch status {
                case .start, .resume:
                    stopSharingButton.layer.cornerRadius = 6
                    shareScreenView.isHidden = false
                default:
                    shareScreenView.isHidden = true
                }
                return
            }

            unsubscribePreviousSpeaker()
            viewModel.setActiveSharer(with: user)
        }
    }

    
    public func onUserActiveAudioChanged(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        if let userArray = userArray, let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            for user in userArray {
                if (user.getID() != myself.getID()) {
                    // doesn't this if-else mean we call changeActiveSpeaker regardless of the value of isActiveSpeakerAudioExist()?
                    if !viewModel.isActiveSpeakerAudioExist() {
                        if user.getID() != viewModel.getActiveSpeaker().getID() {
                            changeActiveSpeaker(with: user)
                        }
                    } else {
                        if user.getID() != viewModel.getActiveSpeaker().getID() {
                            changeActiveSpeaker(with: user)
                        }
                    }
                } else {
                    animateMicBtnUI()
                }
                
                if let userIndexPathList = viewModel.getUserIndex(with: user) {
                    for currentIndex in userIndexPathList {
                        guard let cell = activeSpeakerGalleryCollectionView.cellForItem(at: currentIndex) as? ActiveSpeakerGalleryCollectionViewCell else { return }
                        if currentIndex != IndexPath(item: 0, section: 0) {
                            cell.showSpeakerAnimation()
                        }
                    }
                }
            }
        }
    }
    
    private func changeActiveSpeaker(with user: ZoomVideoSDKUser) {
        // Treat active sharer like an active speaker that does not get replaced until screen share ends
        guard viewModel.getActiveSharer() == nil else { return }
        
        // Unsubscribe previous active speaker videoCanvas first from ActiveSpeakerView
        unsubscribePreviousSpeaker()
        
        // Then set new active speaker
        viewModel.setActiveSpeaker(with: user)
    }
    
    private func unsubscribePreviousSpeaker() {
        let currentActiveSpeaker = viewModel.getActiveSpeaker()
        let activeSpeakerIndexPath = IndexPath(row: 0, section: 0)
        guard let activeSpeakerCell = activeSpeakerGalleryCollectionView.cellForItem(at: activeSpeakerIndexPath) as? ActiveSpeakerGalleryCollectionViewCell else { return }
        currentActiveSpeaker.getVideoCanvas()?.unSubscribe(with: activeSpeakerCell)
    }
    
    public func onUserJoin(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        if let userArray = userArray, let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            for user in userArray {
                if (user.getID() != myself.getID()) {
                    UserManager.shared().addRemoteUsers(with: user)
                    let userIndex = viewModel.addRemoteUserList(with: user)
                    setupParticipantsBtnUI()
                    pageControl.numberOfPages = viewModel.getUpdatedPageControlPage()
                    activeSpeakerGalleryCollectionView.isScrollEnabled = viewModel.shouldShowPageControl()
                    if pageControl.currentPage == viewModel.getUserPage(with: userIndex) {
                        activeSpeakerGalleryCollectionView.reloadItems(at: [IndexPath(item: userIndex, section: 0)])
                    } else {
                        activeSpeakerGalleryCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    public func onUserLeave(_ helper: ZoomVideoSDKUserHelper?, users userArray: [ZoomVideoSDKUser]?) {
        if let userArray = userArray, let myself = ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf() {
            for user in userArray {
                if (user.getID() != myself.getID()) {
                    UserManager.shared().removeRemoteUsers(with: user)
                    
                    _ = viewModel.removeRemoteUserList(with: user)
                    // Reload Data is necessary or we will need to manually update each affected item and will need to find out what is the best way to do this.
                    setupParticipantsBtnUI()
                    pageControl.numberOfPages = viewModel.getUpdatedPageControlPage()
                    activeSpeakerGalleryCollectionView.isScrollEnabled = viewModel.shouldShowPageControl()
                    activeSpeakerGalleryCollectionView.reloadData()
                    if viewModel.isOnlyLocalUserLeft() {
                        activeSpeakerGalleryCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                }
            }
        }
    }
    
    public func onChatNewMessageNotify(_ helper: ZoomVideoSDKChatHelper?, message chatMessage: ZoomVideoSDKChatMessage?) {
        guard let chatMessage = chatMessage else { return }
        ChatManager.shared().addNewChat(chatMessage: chatMessage)
    }
    
    public func onChatPrivilegeChanged(_ helper: ZoomVideoSDKChatHelper?, privilege currentPrivilege: ZoomVideoSDKChatPrivilegeType) {
        ChatManager.shared().changeChatPriviledge(priviledge: currentPrivilege)
        Toast.show(message: "Chat is \(ChatManager.shared().isChatEnabled() ? "enabled" : "disabled").")
    }
    
    public func onUserNameChanged(_ user: ZoomVideoSDKUser?) {
        if let user = user {
            if let userIndexPathList = viewModel.getUserIndex(with: user) {
                for currentIndex in userIndexPathList {
                    if let cell = activeSpeakerGalleryCollectionView.cellForItem(at: currentIndex) as? ActiveSpeakerGalleryCollectionViewCell {
                        viewModel.updateUser(with: user)
                        viewModel.updateActiveSpeakerGalleryCameraView(with: cell, at: currentIndex.row)
                    }
                }
            }
            
            if user == UserManager.shared().getLocalUser() {
                setupVideoBtnUI()
                updateLocalUserVideoView()
                UserManager.shared().updateLocalUser(with: user)
                Toast.show(message: "You got renamed to \(user.getName() ?? "Nil")")
            } else {
                UserManager.shared().updateRemoteUser(with: user)
            }
        }
    }
    
    public func onUserHostChanged(_ helper: ZoomVideoSDKUserHelper?, users user: ZoomVideoSDKUser?) {
        guard let user = user else { return }
        UserManager.shared().updateHost(with: user)
        if UserManager.shared().isLocalUserHost() && UserManager.shared().isUserMyself(with: user) {
            Toast.show(message: "You’ve become the host.")
        }
    }
    
    public func onUserManagerChanged(_ user: ZoomVideoSDKUser?) {
        guard let user = user else { return }
        UserManager.shared().updateManager(with: user)
        if user.isManager() && UserManager.shared().isUserMyself(with: user) {
            Toast.show(message: "You’ve become the manager.")
        } else {
            // Toast.show(message: "\(user?.getName() ?? "Nil") has become the manager.")
        }
    }
    
    private func getFirstRemoteUserWithCameraOrWithout() -> ZoomVideoSDKUser? {
        if let remoteUsers = ZoomVideoSDK.shareInstance()?.getSession()?.getRemoteUsers(), remoteUsers.count > 0 {
            for user in remoteUsers {
                if let cameraIsOn = user.getVideoCanvas()?.videoStatus()?.on, cameraIsOn {
                    return user
                }
            }
            // If none of the remote user has camera on, we will return the first remote user.
            return remoteUsers.first
        }
        return nil
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
// Used for active speaker and gallery view.

@_documentation(visibility:private)
extension UIToolkitVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        
        pageControl.currentPage = Int(offSet + horizontalCenter) / Int(width)
        
        if pageControl.currentPage == 0 {
            UIView.animate(withDuration: 0.5) {
                self.localUserView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.localUserView.alpha = 0
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getActiveSpeakerGalleryCountForCollectionView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let currentCell = cell as? ActiveSpeakerGalleryCollectionViewCell else { return }
        viewModel.getUser(at: indexPath.row)?.getVideoCanvas()?.unSubscribe(with: currentCell.speakerView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let currentCell = cell as? ActiveSpeakerGalleryCollectionViewCell else { return }

        if viewModel.getActiveSharer() == nil {
            viewModel.updateActiveSpeakerGalleryCameraView(with: currentCell, at: indexPath.row)
        } else {
            if indexPath == IndexPath(row: 0, section: 0) {
                viewModel.updateActiveSharerGalleryCameraView(with: currentCell, at: indexPath.row)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: activeSpeakerGalleryCellReuseIdentifier, for: indexPath) as? ActiveSpeakerGalleryCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.row < viewModel.getActiveSpeakerGalleryCount()  {
            cell.isHidden = false
            cell.contentView.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
            let username = viewModel.getActiveSpeakerGalleryName(index: indexPath.row)
            cell.nameLabel.text = username
            cell.showDefaultAvatar(bool: true)
            cell.speakerView.clipsToBounds = true
            
            if indexPath.row != 0 {
                cell.addCustomConstraintToCellView(paddingSize: 6)
                cell.addCornerRadius(size: 8)
            } else {
                cell.addCustomConstraintToCellView(paddingSize: 0)
                cell.addCornerRadius(size: 0)
            }
            
            cell.setupDefaultAvatarView()
            cell.setDefaultAvatarTitle(text: username.getDefaultName, fontSize: indexPath.row == 0 ? 64 : 48)
        } else {
            cell.isHidden = true
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: activeSpeakerGalleryCollectionView.frame.width, height: activeSpeakerGalleryCollectionView.frame.height)
        } else {
            return CGSize(width: activeSpeakerGalleryCollectionView.frame.width / 2, height: activeSpeakerGalleryCollectionView.frame.height / 2)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: UIToolkitViewModelDelegate

@_documentation(visibility:private)
extension UIToolkitVC: UIToolkitViewModelDelegate {
    func updatedActiveSpeaker(isMyself: Bool) {
        localUserView.isHidden = isMyself
        
        let activeSpeakerIndexPath = IndexPath(row: 0, section: 0)
        guard let cell = activeSpeakerGalleryCollectionView.cellForItem(at: activeSpeakerIndexPath) as? ActiveSpeakerGalleryCollectionViewCell else { return }
        
        let username = viewModel.getActiveSpeakerGalleryName(index: 0)
        cell.nameLabel.text = username
        if viewModel.getActiveSharer() == nil {
            viewModel.updateActiveSpeakerGalleryCameraView(with: cell, at: 0)
        } else {
            viewModel.updateActiveSharerGalleryCameraView(with: cell, at: 0)
        }
        cell.setDefaultAvatarTitle(text: username.getDefaultName, fontSize: 64)
    }
}

// MARK: CustomAlertBoxDelegate

@_documentation(visibility:private)
extension UIToolkitVC: CustomAlertBoxDelegate {
    func showUnmuteRequestUI() {
        guard let vc = UIApplication.topViewController() else { return }
        let alertBox = CustomAlertBox()
        alertBox.delegate = self
        alertBox.setButton(title: "The host would like you to turn on your microphone.")
        vc.view.addSubview(alertBox)
        alertBox.fitLayoutTo(view: vc.view)
        alertBox.present()
    }
    
    func onClickConfirmBtn() {
        UserManager.shared().unmuteLocalUser()
    }
}

// MARK: ChatManagerDelegate

@_documentation(visibility:private)
extension UIToolkitVC: ChatManagerDelegate {
    @objc func newMessageReceived() {
        guard let topVC = UIApplication.topViewController(), !topVC.isKind(of: ChatVC.self) else { return }
        moreBtn.addBadgeToButton(badge: "\(ChatManager.shared().getUnreadMessageCount())", withBackground: true)
    }
    
    @objc func unreadMessageRead() {
        let unreadMessageCount = ChatManager.shared().getUnreadMessageCount()
        if unreadMessageCount > 0 {
            moreBtn.addBadgeToButton(badge: "\(unreadMessageCount)")
        } else {
            moreBtn.removeBadge()
        }
    }
}
