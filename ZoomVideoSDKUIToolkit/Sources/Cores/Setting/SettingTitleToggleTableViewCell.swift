//
//  SettingTitleToggleTableViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class SettingTitleToggleTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    var switchDisabledWhenFalse = false
    var switchAction: (() -> Bool)?
    var redirectAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 8
        mainView.layer.backgroundColor = UIColor.white.cgColor
        titleLabel.textColor = UIColor(red: 0.075, green: 0.086, blue: 0.098, alpha: 1)
    }
    
    @IBAction func onClickSwitch(_ sender: UISwitch) {
        guard let switchAction = switchAction else { return }
        let result = switchAction()
        `switch`.isOn = result
        `switch`.isEnabled = !switchDisabledWhenFalse
        
        guard let redirectAction = redirectAction else { return }
        redirectAction()
    }
}
