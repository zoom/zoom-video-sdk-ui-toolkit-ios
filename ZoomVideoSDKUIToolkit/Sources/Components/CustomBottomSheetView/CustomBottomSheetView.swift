//
//  CustomBottomSheetView.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class CustomBottomSheetView: UIView {
    
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var ctaStackView: UIStackView!
    
    var view: UIView!
    
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
        
        bottomSheetView.clipsToBounds = true
        bottomSheetView.layer.cornerRadius = 12
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        cancelBtn.setTitleColor(.black, for: .normal)
        cancelBtn.setTitle("Cancel", for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        view.addGestureRecognizer(tapGesture)
    }
    
    public func present() {
        addSubview(view)
        view.fitLayoutTo(view: self)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            let height:CGFloat = 300
            self.bottomSheetView.frame = CGRect(x: 0, y: self.bottomSheetView.frame.minY - height, width: self.bottomSheetView.frame.width, height: self.bottomSheetView.frame.height)
        }) { completed in
            
        }
        
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.5, animations: {
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func onClickCancelBtn(_ sender: UIButton) {
        dismiss()
    }
}
