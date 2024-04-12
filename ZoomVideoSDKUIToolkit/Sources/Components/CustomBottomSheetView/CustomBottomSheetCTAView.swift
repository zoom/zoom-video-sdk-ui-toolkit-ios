//
//  CustomBottomSheetCTAView.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class CustomBottomSheetCTAView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var ctaLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    var view: UIView!
    var callToAction: (() -> Void)?
    
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
        addSubview(view)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 56).isActive = true
        view.fitLayoutTo(view: self)
        badgeView.isHidden = true
    }
    
    public func setButton(image: String? = nil, title text:String, titleBold: Bool = false, textColor color: UIColor = .black, action cta: (() -> Void)? = nil) {
        if image == nil {
            iconImageView.isHidden = true
        }
        
        iconImageView.isHidden = image == nil
        
        if let image = image {
            iconImageView.image = UIImage(named: image, in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = color
        }
        
        ctaLabel.text = text
        ctaLabel.textColor = color
            
        if titleBold {
            ctaLabel.font = .boldSystemFont(ofSize: 17)
        } else {
            ctaLabel.font = .systemFont(ofSize: 17)
        }
        
        if cta != nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(performCTA))
            callToAction = cta
            contentView.isUserInteractionEnabled = true
            contentView.addGestureRecognizer(tapGesture)
        }
    }
    
    public func setupBadgeUI(hidden: Bool, with title: String? = "") {
        badgeLabel.text = title
        badgeView.isHidden = hidden
        badgeView.layoutIfNeeded()
        if title != "" {
            badgeView.layer.cornerRadius = badgeView.frame.height / 2
            badgeView.layer.masksToBounds = true
            badgeView.backgroundColor = UIColor(red: 0.84, green: 0.29, blue: 0.25, alpha: 1)
        }
    }
    
    @objc private func performCTA() {
        guard let callToAction = callToAction else { return }
        callToAction()
    }
    
}
