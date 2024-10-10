//
//  SettingsVC.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit
import ZoomVideoSDK

enum LocalUserSetting {
    case Personal
    case Session
    
    var title: String {
        switch self {
        case .Personal:
            return "My Name"
        case .Session:
            return "Allow all participants to"
        }
    }
    
    var userSetting: [UserSetting]? {
        switch self {
        case .Personal:
            return [.ChangeName, .SessionInfo, .Statistics]
        case .Session:
            return nil
        }
    }
    
    var sessionSetting: [SessionSetting]? {
        switch self {
        case .Personal:
            return nil
        case .Session:
            return [.Chat] // Note: This controls what session settings to be configurable
        }
    }
}

enum UserSetting: String {
    case Mute
    case Host
    case Manager
    case ChangeName
    case RemoveFromSession
    case SessionInfo
    case Statistics

    var title: (String) {
        switch self {
        case .Mute:
            return "Mute Microphone"
        case .Host:
            return "Host"
        case .Manager:
            return "Manager"
        case .ChangeName:
            return ZoomVideoSDK.shareInstance()?.getSession()?.getMySelf()?.getName() ?? "Not available"
        case .RemoveFromSession:
            return "Remove from session"
        case .SessionInfo:
            return "Session information"
        case .Statistics:
            return "Statistics"
        }
    }
    
    var buttonTitle: (String) {
        switch self {
        case .Host:
            return "Assign"
        case .RemoveFromSession:
            return "Remove"
        case .Mute, .Manager, .ChangeName, .SessionInfo, .Statistics:
            return ""
        }
    }
    
    var settingType: (SettingType) {
        switch self {
        case .Mute:
            return .TitleToggle
        case .Host:
            return .TitleButton
        case .Manager:
            return .TitleToggle
        case .ChangeName:
            return .TitleTextField
        case .RemoveFromSession:
            return .TitleButton
        case .SessionInfo:
            return .TitleButton
        case .Statistics:
            return .TitleButton
        }
    }
}

enum SessionSetting {
    case Chat
    case Sharing
    case VirtualBackground
    
    var title: String {
        switch self {
        case .Chat:
            return "Chat"
        case .Sharing:
            return "Screen sharing"
        case .VirtualBackground:
            return "Virtual background"
        }
    }
    
}

enum SettingType {
    case TitleToggle
    case TitleButton
    case TitleTextField
}

class SettingsVC: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var titleToggleReuseIdentifier = "SettingTitleToggleTableViewCell"
    private var titleButtonReuseIdentifier = "SettingTitleButtonTableViewCell"
    private var titleTextFieldReuseIdentifier = "SettingTitleTextFieldTableViewCell"
    private var titleTapReuseIdentifier = "SettingTitleTapTableViewCell"
    
    private var user: ZoomVideoSDKUser!
    
    public init() {
        super.init(
            nibName: String(describing: SettingsVC.self),
            bundle: Bundle(for: SettingsVC.self)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = UserManager.shared().getLocalUser() else { return }
        self.user = user
        setupUI()
    }
    
    private func setupUI() {
        setupNavBar()
        
        // Note: This helps to remove the spacing after section header and is only available from 15 onwards.
        // This means that lower than iOS 15 won't have this space issue.
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UINib(nibName: titleToggleReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: titleToggleReuseIdentifier)
        tableView.register(UINib(nibName: titleButtonReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: titleButtonReuseIdentifier)
        tableView.register(UINib(nibName: titleTextFieldReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: titleTextFieldReuseIdentifier)
        tableView.register(UINib(nibName: titleTapReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: titleTapReuseIdentifier)
        tableView.backgroundColor = UIColor(red: 0.969, green: 0.976, blue: 0.98, alpha: 1)
        tableView.separatorStyle = .none
    }
    
    func setupNavBar() {
        var navItem = UINavigationItem()
        navItem = UINavigationItem(title: "Settings")
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "ChevronLeft", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: backBtn)
        navItem.leftBarButtonItem = menuBarItem
        navItem.titleView?.tintColor = .black
        
        navigationBar.items = [navItem]
        navigationBar.barTintColor = UIColor(red: 0.969, green: 0.976, blue: 0.98, alpha: 1)
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    func getUsernameAndRole(with user: ZoomVideoSDKUser) -> String {
        let username = user.getName() ?? ""
        var userRole = ""
        
        if user.isHost() {
            userRole = " - Host"
        } else if user.isManager() {
            userRole = " - Manager"
        }
        
        return username + userRole
    }
    
    @objc private func backAction() {
        guard let topVC = UIApplication.topViewController() else { return }
        topVC.dismissDetail()
    }
    
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MoreOptionManager.shared().getLocalUserSettings().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch MoreOptionManager.shared().getLocalUserSettings()[section] {
        case .Personal:
            return MoreOptionManager.shared().getLocalUserSettings()[section].userSetting?.count ?? 0
        case .Session:
            return MoreOptionManager.shared().getLocalUserSettings()[section].sessionSetting?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch MoreOptionManager.shared().getLocalUserSettings()[indexPath.section] {
        case .Personal:
            guard let userSetting = MoreOptionManager.shared().getLocalUserSettings()[indexPath.section].userSetting else { return UITableViewCell() }
            
            switch userSetting[indexPath.row] {
            case .ChangeName:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: titleTapReuseIdentifier, for: indexPath) as? SettingTitleTapTableViewCell else { return UITableViewCell() }
                
                cell.titleLabel.text = userSetting[indexPath.row].title
                cell.delegate = self
                let tapGesture = UITapGestureRecognizer(target: cell, action: #selector(cell.presentChangeNameView))
                cell.mainView.addGestureRecognizer(tapGesture)

                return cell
            case .SessionInfo:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: titleTapReuseIdentifier, for: indexPath) as? SettingTitleTapTableViewCell else { return UITableViewCell() }

                cell.titleLabel.text = userSetting[indexPath.row].title
                cell.delegate = self
                let tapGesture = UITapGestureRecognizer(target: cell, action: #selector(cell.presentSessionInfoView))
                cell.mainView.addGestureRecognizer(tapGesture)

                return cell
                
            case .Statistics:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: titleTapReuseIdentifier, for: indexPath) as? SettingTitleTapTableViewCell else { return UITableViewCell() }

                cell.titleLabel.text = userSetting[indexPath.row].title
                cell.delegate = self
                let tapGesture = UITapGestureRecognizer(target: cell, action: #selector(cell.presentStatisticsView))
                cell.mainView.addGestureRecognizer(tapGesture)

                return cell


            case .Host, .Manager, .Mute, .RemoveFromSession:
                return UITableViewCell()
            }
        case .Session:
            guard let sessionSetting = MoreOptionManager.shared().getLocalUserSettings()[indexPath.section].sessionSetting else { return UITableViewCell() }
            
            let currentSessionSetting = sessionSetting[indexPath.row]
            switch currentSessionSetting {
            case .Chat, .Sharing, .VirtualBackground:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: titleToggleReuseIdentifier, for: indexPath) as? SettingTitleToggleTableViewCell else { return UITableViewCell() }
                
                cell.titleLabel.text = MoreOptionManager.shared().getLocalUserSettings()[indexPath.section].sessionSetting?[indexPath.row].title ?? "Nil"
                
                if currentSessionSetting == .Chat {
                    cell.switch.isOn = MoreOptionManager.shared().isChatAllowed()
                    
                    switch MoreOptionManager.shared().getChatSettings() {
                    case .everyone_Publicly_And_Privately, .no_One:
                        cell.switchAction = MoreOptionManager.shared().changeChatPrivilege
                    default:
                        break
                    }
                } else if currentSessionSetting == .Sharing {
                    cell.switch.isOn = false
                    cell.switch.isEnabled = false
                } else if currentSessionSetting == .VirtualBackground {
                    // TODO: Virtual Background P1
                    cell.switch.isOn = false
                    cell.switch.isEnabled = false
                }
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = MoreOptionManager.shared().getLocalUserSettings()[section].title
        label.font = .systemFont(ofSize: 16)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
}

extension SettingsVC: SettingTitleTextFieldTableViewCellDelegate {
    func userHitDone(with text: String, cell: SettingTitleTextFieldTableViewCell) {
        if MoreOptionManager.shared().changeName(user: user, with: text) {
            cell.textField.placeholder = text
        }
    }
}

extension SettingsVC: SettingTitleTapFieldTableViewCellDelegate {
    func userHitDone(with text: String, cell: SettingTitleTapTableViewCell) {
        if MoreOptionManager.shared().changeName(user: user, with: text) {
            cell.titleLabel.text = text
        }
    }
}
