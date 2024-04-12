//
//  Loader.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import UIKit

class Loader: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var view: UIView!
    var targetView: UIView!
    
    required init(forView view: UIView) {
        super.init(frame: view.bounds)
        targetView = view
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        view = loadViewFromNib()
        view.frame = targetView.frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        targetView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func showLoading(withText text: String, withCompletion completion: (() -> Swift.Void)? = nil) {
        titleLabel.text = text
        targetView.addSubview(view)
        UIView.animate(withDuration: 5, animations: {
        }) { _ in
            completion?()
        }
    }

    func hideLoading() {
        UIView.animate(withDuration: 0.5, animations: {
        }) { _ in
            self.view.removeFromSuperview()
        }
    }
}
