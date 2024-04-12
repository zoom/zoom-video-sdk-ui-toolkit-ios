//
//  SettingTableViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2023 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var chevronRightImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 8
        mainView.layer.backgroundColor = UIColor.clear.cgColor
        chevronRightImageView.image = UIImage(named: "ChevronRight", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
        chevronRightImageView.tintColor = .black
    }
    
    func selectCell(isSelected: Bool) {
        if isSelected {
            chevronRightImageView.tintColor = .white
        } else {
            chevronRightImageView.tintColor = .black
        }
    }
}
