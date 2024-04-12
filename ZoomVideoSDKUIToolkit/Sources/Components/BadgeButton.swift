//
//  BadgeButton.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class BadgeButton: UIButton {

    var badgeLabel = UILabel()

    var badge: String? {
        didSet {
            addBadgeToButton(badge: badge)
        }
    }

    public var badgeTextColor = UIColor.black {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }

    public var badgeFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }

    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToButton(badge: badge)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToButton(badge: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addBadgeToButton(badge: nil)
    }

    func addBadgeToButton(badge: String?, withBackground: Bool? = false) {
        badgeLabel.text = badge
        badgeLabel.textColor = badgeTextColor
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        let badgeSize = badgeLabel.frame.size
        
        let height = max(10, Double(badgeSize.height))
        let width = max(height, Double(badgeSize.width))
        
        var vertical: Double?, horizontal: Double?
        
        if let withBackground = withBackground, withBackground {
            if let badgeInset = self.badgeEdgeInsets {
                vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
                horizontal = Double(badgeInset.left) - Double(badgeInset.right)
                
                let x = (Double(bounds.size.width) - 25 + horizontal!)
                let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
                badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
            } else {
                let x = self.frame.width - CGFloat((width / 2.0) + 20)
                let y = CGFloat(-(height / 2.0) + 16)
                badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
            }
            
            badgeLabel.backgroundColor = UIColor(red: 0.84, green: 0.29, blue: 0.25, alpha: 1)
            badgeLabel.layer.cornerRadius = badgeLabel.frame.width / 2
            badgeFont = .systemFont(ofSize: 10)
            badgeLabel.textColor = .white
        } else {
            if let badgeInset = self.badgeEdgeInsets {
                vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
                horizontal = Double(badgeInset.left) - Double(badgeInset.right)
                
                let x = (Double(bounds.size.width) - 10 + horizontal!)
                let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
                badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
            } else {
                let x = self.frame.width - CGFloat((self.frame.width / 2.0)) + CGFloat(self.currentImage?.size.width ?? 0 / 2.0) - 5
                let y = CGFloat(-(height / 2.0) + 16)
                badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
            }
        }
        
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        badgeLabel.isHidden = badge != nil ? false : true
    }
    
    func removeBadge() {
        badgeLabel.removeFromSuperview()
    }
    
}
