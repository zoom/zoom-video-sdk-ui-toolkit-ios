//
//  ChatVC.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit
import ZoomVideoSDK

@_documentation(visibility:private)
class ChatVC: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var ctaView: UIView!
    @IBOutlet weak var ctaViewBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var participantButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var sendChatButton: UIButton!
    
    private let cellReuseIdentifier = "ChatTableViewCell"
    private var timer: Timer?
    
    public init() {
        super.init(
            nibName: String(describing: ChatVC.self),
            bundle: Bundle(for: ChatVC.self)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ChatManager.shared().resetUnreadMessage()
        ChatManager.shared().resetSelectedParticipant()
    }
    
    override func viewWillLayoutSubviews() {
        ctaView.addBorder(toSide: .Top, withColor: UIColor(red: 0.906, green: 0.906, blue: 0.906, alpha: 1).cgColor, andThickness: 1)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
        super.viewDidDisappear(animated)
    }
    
    private func setupUI() {
        let crossBtn = UIButton(type: .custom)
        crossBtn.setImage(UIImage(named: "ChevronLeft", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate), for: .normal)
        crossBtn.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        crossBtn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: crossBtn)
        let navItem = UINavigationItem(title: "Chat")
        navItem.leftBarButtonItem = menuBarItem
        navItem.titleView?.tintColor = .black
        
        navBar.items = [navItem]
        navBar.barTintColor = .white
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.register(UINib(nibName: cellReuseIdentifier, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: cellReuseIdentifier)
        chatTableView.allowsSelection = false
        chatTableView.backgroundColor = .white
        
        let participantBtnImage = UIImage(named: "ChevronDown", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
            .resizedImage(Size: CGSize(width: 16, height: 16))
        participantButton.setTitle(ChatManager.shared().getSendParticipant()?.getName() ?? "Everyone", for: .normal)
        participantButton.semanticContentAttribute = .forceRightToLeft
        participantButton.imageView?.contentMode = .scaleAspectFit
        participantButton.frame.size = CGSize(width: 84, height: 20)
        participantButton.setImage(participantBtnImage, for: .normal)
        participantButton.contentHorizontalAlignment = .left
        
        chatTextField.text = ""
        chatTextField.attributedPlaceholder = NSAttributedString(string: "Enter message...", attributes: [.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)])
        chatTextField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        chatTextField.layer.borderWidth = 1
        chatTextField.layer.cornerRadius = 6
        chatTextField.returnKeyType = .send
        chatTextField.delegate = self
        
        sendChatButton.setTitle("", for: .normal)
        sendChatButton.layer.cornerRadius = 6
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageReceived), name: .newMessageReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupData() {
        setupDateTimeLabel()
        ChatManager.shared().delegate = self
    }
    
    @objc private func closeVC() {
        guard let topVC = UIApplication.topViewController() else { return }
        topVC.dismissDetail()
    }
    
    private func setupDateTimeLabel() {
        updateTimeLabel()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true);
    }
    
    @objc private func updateTimeLabel() {
        let date = Date()
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        timeLabel.text = "\(hours > 9 ? "" : "0")\(hours):\(minutes > 9 ? "" : "0")\(minutes)"
    }
    
    @IBAction func onClickParticipantBtn(_ sender: UIButton) {
        guard let topVC = UIApplication.topViewController() else { return }
        let assignHostVC = ParticipantsVC(entryPoint: .Chat)
        assignHostVC.modalPresentationStyle = .custom
        topVC.presentDetail(assignHostVC)
    }
    
    @IBAction func onClickSendChatBtn(_ sender: UIButton) {
        checkAndSendText()
    }
    
    private func checkAndSendText() {
        guard let text = chatTextField.text, text.count > 0 else { return }
        if ChatManager.shared().sendChat(text: text) {
            chatTextField.text?.removeAll()
            chatTextField.resignFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            if let bottomLength = keyWindow?.safeAreaInsets.bottom {
                ctaViewBtmConstraint.constant += keyboardSize.height - bottomLength
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        ctaViewBtmConstraint.constant = 0
    }
    
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ChatManager.shared().getChatMessages().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? ChatTableViewCell, let chatMessage = ChatManager.shared().getMessage(at: indexPath.section) else { return UITableViewCell() }
        cell.setup(with: chatMessage)
        return cell
    }
    
    
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: UITextFieldDelegate

@_documentation(visibility:private)
extension ChatVC: UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkAndSendText()
        return true
    }
}

// MARK: ChatManagerDelegate

@_documentation(visibility:private)
extension ChatVC: ChatManagerDelegate {
    func newChatParticipantSelected() {
        participantButton.setTitle(ChatManager.shared().getSendParticipant()?.getName() ?? "Everyone", for: .normal)
    }
    
    @objc func newMessageReceived() {
        chatTableView.reloadData()
        chatTableView.scrollToBottom()
    }
    
    func chatPrivilegeChanged(enabled: Bool) {
        // Currently there is no requirement to check if priviledge is (both public and private)
        // or (public).
        if !enabled {
            Toast.show(message: "Chat is disabled.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dismiss(animated: true)
            }
        }
    }
}
