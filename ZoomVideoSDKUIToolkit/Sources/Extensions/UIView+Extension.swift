//
//  UIView+Extension.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

extension UIView {
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView

        return nibView
    }
    
    func fitLayoutTo(view parentView: UIView) {
        self.frame = parentView.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .Left: border.frame = CGRect(x: 0.0, y: 0.0, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.width-thickness, y: 0.0, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: 0.0, y: frame.height-thickness, width: frame.width, height: thickness); break
        }
        
        layer.addSublayer(border)
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
