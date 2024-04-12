//
//  SettingTitleTapTableViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

protocol SettingTitleTapFieldTableViewCellDelegate: AnyObject {
    func userHitDone(with text: String, cell: SettingTitleTapTableViewCell)
}

/*
 The SettingTitleTapTableViewCell is for SettingsVC's tableView.
 The xib contains a titleLabel on the left and a cheronRight image on the right while also the whole tableView are clickable with its own delegate.
 If more customization (e.g. Title font/colour, image colour/size) are needed for such design, please modify this directly.
 */
class SettingTitleTapTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tapImageView: UIImageView!

    weak var delegate: SettingTitleTapFieldTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 8
        mainView.layer.backgroundColor = UIColor.white.cgColor
        titleLabel.textColor = UIColor(red: 0.075, green: 0.086, blue: 0.098, alpha: 1)
        tapImageView.image = UIImage(named: "ChevronRight", in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
        tapImageView.tintColor = UIColor(red: 0.075, green: 0.086, blue: 0.098, alpha: 1)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentChangeNameView))
        mainView.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentChangeNameView() {
        guard let vc = UIApplication.topViewController() else { return }
        let customAlertUI = CustomAlertBox()
        customAlertUI.setButton(title: "Edit your name", textFieldPlaceholder: titleLabel.text ?? "Nil")
        customAlertUI.delegate = self
        vc.view.addSubview(customAlertUI)
        customAlertUI.fitLayoutTo(view: vc.view)
        customAlertUI.present()
    }
    
}

extension SettingTitleTapTableViewCell: CustomAlertBoxDelegate {
    func onClickConfirmBtnWithTextField(text: String) {
        delegate?.userHitDone(with: text, cell: self)
    }
}
