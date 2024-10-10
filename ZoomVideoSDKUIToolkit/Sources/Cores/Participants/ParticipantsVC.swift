//
//  ParticipantsVC.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

enum ParticipantsVCEntryPoint {
    case Chat // Select a specific participant for 1-1 chat
    case ShowInformation // Used to display all participants under participant button
    case LeaveAndReassignHost // Used to display all participants except the local user (host) when leaving session
}

class ParticipantsVC: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ctaBtn: CustomUIButton!
    @IBOutlet weak var ctaBtn2: CustomUIButton!
    
    @IBOutlet weak var btnStackViewBottomConstrant: NSLayoutConstraint!
    
    private let cellReuseIdentifier = "ParticipantTableViewCell"
    private let viewModel: ParticipantsViewModel!
    private var successAction: (() -> ())? // ctaBtn: Current use for leave and reassign host
    
    var entryPoint: ParticipantsVCEntryPoint = .ShowInformation
    
    public init(entryPoint: ParticipantsVCEntryPoint = .ShowInformation) {
        viewModel = ParticipantsViewModel(entryPoint: entryPoint)
        self.entryPoint = entryPoint
        super.init(
            nibName: String(describing: ParticipantsVC.self),
            bundle: Bundle(for: ParticipantsVC.self)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserManager.shared().delegate = self
        setupUI()
    }

    private func setupUI() {
        setupNavBar()
        tableView.register(UINib(nibName: cellReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }
    
    private func setupNavBar() {
        var navItem: UINavigationItem
        
        switch entryPoint {
        case .Chat:
            navItem = UINavigationItem(title: "Send to")
            ctaBtn.isHidden = true
            ctaBtn2.isHidden = true
            tableView.allowsSelection = true
        case .ShowInformation:
            navItem = UINavigationItem(title: "Participants")
            ctaBtn.setTitle("Mute all", for: .normal)
            ctaBtn.setTitleColor(.black, for: .normal)
            ctaBtn.layer.borderWidth = 1
            ctaBtn.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1).cgColor
            ctaBtn2.setTitle("Ask all to unmute", for: .normal)
            ctaBtn2.setTitleColor(.black, for: .normal)
            ctaBtn2.layer.borderWidth = 1
            ctaBtn2.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1).cgColor
            
            let isLocalUserHostOrManager = UserManager.shared().isLocalUserHostOrManager()
            ctaBtn.isHidden = !isLocalUserHostOrManager
            ctaBtn2.isHidden = !isLocalUserHostOrManager
            
            tableView.allowsSelection = isLocalUserHostOrManager
        case .LeaveAndReassignHost:
            navItem = UINavigationItem(title: "Assign a host")
            ctaBtn.setTitle("Assign and leave", for: .normal)
            ctaBtn.backgroundColor = UIColor(red: 242/255, green: 243/255, blue: 1, alpha: 1)
            ctaBtn.setTitleColor(UIColor(red: 0, green: 82/255, blue: 217/255, alpha: 1), for: .normal)
            ctaBtn.setTitleColor(UIColor(red: 181/255, green: 199/255, blue: 1, alpha: 1), for: .disabled)
            ctaBtn2.isHidden = true
            
            tableView.allowsSelection = true
        }
        
        let crossBtn = UIButton(type: .custom)
        crossBtn.setImage(UIImage(named: "ChevronLeft", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
        crossBtn.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        crossBtn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: crossBtn)
        navItem.leftBarButtonItem = menuBarItem
        navItem.titleView?.tintColor = .black
        
        navigationBar.items = [navItem]
        navigationBar.barTintColor = .white
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]

        // This is needed to remove top and bottom line
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = UIColor(red: 0.953, green: 0.953, blue: 0.953, alpha: 1)
            searchBar.searchTextField.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            searchBar.searchTextField.placeholder = "Search for participant"
            searchBar.searchTextField.leftView?.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        } else {
            // TODO: Fallback on earlier versions
        }
        
        ctaBtn.layer.cornerRadius = 6
        ctaBtn2.layer.cornerRadius = 6
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            if let bottomLength = keyWindow?.safeAreaInsets.bottom {
                btnStackViewBottomConstrant.constant += keyboardSize.height - bottomLength
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        btnStackViewBottomConstrant.constant = 16
    }
    
    @objc private func closeVC() {
        guard let topVC = UIApplication.topViewController() else { return }
        topVC.dismissDetail()
    }
    
    @IBAction func onClickCTABtn(_ sender: UIButton) {
        switch entryPoint {
        case .Chat:
            break
        case .ShowInformation:
            UserManager.shared().presentMuteUsersUI()
        case .LeaveAndReassignHost:
            guard let selectedRow = tableView.indexPathForSelectedRow?.row else { return }
            UserManager.shared().assignNewHost(at: selectedRow) { success in
                if success {
                    self.dismiss(animated: true)
                    guard let successAction = self.successAction else { return }
                    successAction()
                } else {
                    ErrorManager.shared().getDelegate()?.onError(.ChangeHostFailed)
                    self.alertError(with: .ChangeHostFailed, dismiss: false)
                }
            }
        }
    }
    
    @IBAction func onClickCTABtn2(_ sender: Any) {
        switch entryPoint {
        case .ShowInformation:
            UserManager.shared().askAllUsersToUnmute()
        case .Chat, .LeaveAndReassignHost:
            break
        }
    }
    
    public func setSuccessAction(with action: @escaping () -> ()) {
        successAction = action
    }
    
}

extension ParticipantsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if entryPoint == .Chat {
            return viewModel.getParticipantsCount() + 1
        } else {
            return viewModel.getParticipantsCount()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? ParticipantTableViewCell else { return UITableViewCell() }
        
        switch entryPoint {
        case .LeaveAndReassignHost, .ShowInformation:
            guard let currentUser = viewModel.getParticipant(at: indexPath.row) else { return UITableViewCell() }
            
            if entryPoint == .LeaveAndReassignHost {
                cell.setCell(avatarName: currentUser.getName()?.getDefaultName ?? "NA", name: currentUser.getNameWithRole())
            } else {
                let audioIsOn = UserManager.shared().isUserMicOn(with: currentUser)
                let audioImage = UIImage(named: audioIsOn ? "Mic" : "Mic-Disabled", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate).resizedImage(Size: CGSize(width: 20, height: 20)) ?? UIImage()
                let audioBtnColor: UIColor = audioIsOn ? .black : .red
                
                let videoIsOn = UserManager.shared().isUserVideoOn(with: currentUser)
                let videoImage = UIImage(named: videoIsOn ? "Video" : "Video-Disabled", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate).resizedImage(Size: CGSize(width: 20, height: 20)) ?? UIImage()
                let videoBtnColor: UIColor = videoIsOn ? .black : .red
                
                cell.setCell(avatarName: currentUser.getName()?.getDefaultName ?? "NA", name: currentUser.getNameWithRole(), ctaImage: audioImage, ctaImageColor: audioBtnColor, ctaImage2: videoImage, ctaImage2Color: videoBtnColor)
            }
            
            cell.isUserInteractionEnabled = !UserManager.shared().isUserMyself(with: currentUser)
        case .Chat:
            if indexPath.row == 0 {
                cell.setCell(avatarIcon: "Team", name: "Everyone")
            } else {
                guard let currentUser = viewModel.getParticipant(at: indexPath.row - 1) else { return UITableViewCell() }
                cell.setCell(avatarName: currentUser.getName()?.getDefaultName ?? "NA", name: currentUser.getNameWithRole())
            }
            
            cell.isUserInteractionEnabled = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if entryPoint == .LeaveAndReassignHost && indexPath.row == 0 {
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            ctaBtn.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch entryPoint {
        case .Chat:
            if indexPath.row == 0 {
                ChatManager.shared().selectSendParticipant()
            } else {
                guard let currentUser = viewModel.getParticipant(at: indexPath.row - 1) else { return }
                ChatManager.shared().selectSendParticipant(user: currentUser)
            }
            self.dismissDetail()
        case .ShowInformation:
            if let currentUser = viewModel.getParticipant(at: indexPath.row) {
                UserManager.shared().showUserControlUI(with: currentUser)
            }
        case .LeaveAndReassignHost:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}

extension ParticipantsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setFilterText(text: searchText)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ParticipantsVC: UserManagerDelegate {
    func addedRemoteUser(index: Int) {
        tableView.reloadData()
    }
    
    func updatedRemoteUser(index: Int) {
        tableView.reloadData()
    }
    
    func removedRemoteUser(index: Int) {
        tableView.reloadData()
    }
    
    func updatedLocalUser() {
        tableView.reloadData()
    }
    
    func mutedCurrentUser(index: Int) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ParticipantTableViewCell else { return }
        let audioImage = UIImage(named: "Mic-Disabled", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate).resizedImage(Size: CGSize(width: 20, height: 20)) ?? UIImage()
        let audioBtnColor: UIColor = .red
        cell.setCTABtn(ctaImage: audioImage, ctaImageColor: audioBtnColor)
    }
    
    func unmutedLocalUser() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ParticipantTableViewCell else { return }
        let audioImage = UIImage(named: "Mic", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate).resizedImage(Size: CGSize(width: 20, height: 20)) ?? UIImage()
        let audioBtnColor: UIColor = .black
        cell.setCTABtn(ctaImage: audioImage, ctaImageColor: audioBtnColor)
    }
    
    func changedHost() {
        setupUI()
        tableView.reloadData()
    }
    
    func changedManager() {
        setupUI()
        tableView.reloadData()
    }
}

class CustomUIButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = UIColor(red: 242/255, green: 243/255, blue: 1, alpha: 1)
        }
    }
}
