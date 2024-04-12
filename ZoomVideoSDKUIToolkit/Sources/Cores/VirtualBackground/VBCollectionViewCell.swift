//
//  VBCollectionViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class VBCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderColor = isSelected ? UIColor(red: 0, green: 0.32, blue: 0.85, alpha: 1).cgColor : UIColor.clear.cgColor
            imageView.layer.borderWidth = isSelected ? 2 : 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 8
    }
    
    public func setCell(image path: String) {
        imageView.image = UIImage(named: path, in: Bundle(for: type(of: self)), compatibleWith: .none)
    }

}
