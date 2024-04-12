//
//  ChatTableViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit
import ZoomVideoSDK

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileInitialLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var messageByMe = true {
        didSet {
            if messageByMe {
                messageView.backgroundColor = UIColor(red: 217/255, green: 225/255, blue: 255/255, alpha: 1)
            } else {
                messageView.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileInitialLabel.font = .boldSystemFont(ofSize: 12)
        profileInitialLabel.layer.cornerRadius = 8
        profileInitialLabel.layer.masksToBounds = true
        
        messageView.layer.cornerRadius = 12
        messageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        
        if messageByMe {
            messageView.backgroundColor = UIColor(red: 217/255, green: 225/255, blue: 255/255, alpha: 1)
        } else {
            messageView.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
        }
        
        messageLabel.numberOfLines = 0
    }
    
    public func setup(with chatMessage: ZoomVideoSDKChatMessage) {
        guard let sender = chatMessage.senderUser, let senderName = sender.getName() else { return }
        let senderText = UserManager.shared().isUserMyself(with: sender) ? "You" : senderName
        let isMessageForAll = chatMessage.isChatToAll
        var receiverText = ""
        if isMessageForAll {
            receiverText = "Everyone"
        } else {
            if let receiver = chatMessage.receiverUser {
                receiverText = ((UserManager.shared().isUserMyself(with: receiver) ? "You" : receiver.getName()) ?? "Nil")
            }
        }

        usernameLabel.text = senderText + " to " + receiverText
        profileInitialLabel.text = senderName.getDefaultName
        profileInitialLabel.textColor = .white
        profileInitialLabel.textAlignment = .center
        profileInitialLabel.backgroundColor = chatMessage.isSelfSend ? UIColor(red: 0, green: 82/255, blue: 217/255, alpha: 1) : UIColor(red: 0.98, green: 0.33, blue: 0.11, alpha: 1)
        backgroundColor = .clear
        
        messageByMe = chatMessage.isSelfSend
        messageLabel.text = chatMessage.content
    }

}
