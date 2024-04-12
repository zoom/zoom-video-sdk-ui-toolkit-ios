//
//  SettingTitleButtonTableViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class SettingTitleButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var callToActionBtn: UIButton!
    
    var buttonAction: (() -> Bool)?
    var redirectAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 8
        mainView.layer.backgroundColor = UIColor.white.cgColor
        titleLabel.textColor = UIColor(red: 0.075, green: 0.086, blue: 0.098, alpha: 1)
        callToActionBtn.setTitleColor(.white, for: .disabled)
    }
    
    @IBAction func onClickCallToActionBtn(_ sender: UIButton) {
        guard let buttonAction = buttonAction else { return }
        let result = buttonAction()
        if result == true {
            callToActionBtn.isEnabled = false
            guard let redirectAction = redirectAction else { return }
            redirectAction()
        }
    }
}
