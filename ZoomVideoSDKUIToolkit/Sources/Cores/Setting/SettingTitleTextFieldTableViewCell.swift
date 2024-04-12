//
//  SettingTitleTextFieldTableViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

protocol SettingTitleTextFieldTableViewCellDelegate: AnyObject {
    func userHitDone(with text: String, cell: SettingTitleTextFieldTableViewCell)
}

class SettingTitleTextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: SettingTitleTextFieldTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 8
        mainView.layer.backgroundColor = UIColor.white.cgColor
        titleLabel.textColor = UIColor(red: 0.075, green: 0.086, blue: 0.098, alpha: 1)
        textField.textColor = .black
        textField.returnKeyType = .done
        textField.delegate = self
    }
    
}

extension SettingTitleTextFieldTableViewCell: UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count > 0 {
            delegate?.userHitDone(with: text, cell: self)
            textField.text?.removeAll()
            textField.resignFirstResponder()
        }
        return true
    }
}
