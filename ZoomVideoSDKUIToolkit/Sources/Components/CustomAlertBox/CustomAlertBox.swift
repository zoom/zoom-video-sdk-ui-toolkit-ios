//
//  CustomAlertBox.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

protocol CustomAlertBoxDelegate: AnyObject {
    func onClickCancelBtn()
    func onClickConfirmBtn()
    func onClickConfirmBtnWithTextField(text: String)
}

extension CustomAlertBoxDelegate {
    func onClickCancelBtn() {}
    func onClickConfirmBtn() {}
    func onClickConfirmBtnWithTextField(text: String) {}
}

class CustomAlertBox: UIView {
    
    @IBOutlet weak var alertBoxView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var view: UIView!
    
    weak var delegate: CustomAlertBoxDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // Note: Cannot have custom required init that takes in Parent View because it will caused all the IBOutlet and IBAction to be not recognized.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        view = loadViewFromNib()
        alertBoxView.clipsToBounds = true
        alertBoxView.layer.cornerRadius = 12
        textField.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 220/255).cgColor
        textField.layer.borderWidth = 1
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 6
    }
    
    @IBAction func onClickCancelBtn(_ sender: UIButton) {
        delegate?.onClickCancelBtn()
        textField.resignFirstResponder()
        removeFromSuperview()
    }
    
    @IBAction func onClickConfirmBtn(_ sender: UIButton) {
        if let _ = textField.placeholder?.isEmpty {
            delegate?.onClickConfirmBtnWithTextField(text: textField.text ?? "")
        } else {
            delegate?.onClickConfirmBtn()
        }
        removeFromSuperview()
    }
    
    public func setButton(title: String, description: String = "", textFieldPlaceholder: String = "", shouldHideCancelBtn: Bool = false) {
        titleLabel.text = title
        if description.isEmpty {
            descriptionLabel.isHidden = true
        } else {
            descriptionLabel.text = description
        }
        
        if textFieldPlaceholder.isEmpty {
            textField.isHidden = true
        } else {
            textField.attributedPlaceholder = NSAttributedString(string: textFieldPlaceholder, attributes: [.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)])
            textField.delegate = self
        }
        
        cancelBtn.isHidden = shouldHideCancelBtn
    }
    
    public func present() {
        addSubview(view)
        view.fitLayoutTo(view: self)
        alertBoxView.alpha = 0
        
        UIView.animate(withDuration: 0.25, animations: {
        }) { _ in
            self.alertBoxView.alpha = 1
        }
    }
    
}

extension CustomAlertBox: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count > 0 {
            delegate?.onClickConfirmBtnWithTextField(text: textField.text ?? "")
            textField.text?.removeAll()
            textField.resignFirstResponder()
            removeFromSuperview()
        }
        return true
    }
}
