//
//  ActiveSpeakerGalleryCollectionViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class ActiveSpeakerGalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var speakerView: UIView!
    @IBOutlet weak var defaultAvatarView: UIView!
    @IBOutlet weak var defaultAvatarLabel: UILabel!
    @IBOutlet weak var imageSpeakerNameView: UIView!
    @IBOutlet weak var micImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var defaultAvatarViewWidth: NSLayoutConstraint!
    
    let audioMicImageName = "Mic-Disabled"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageSpeakerNameView.layer.cornerRadius = 8
        defaultAvatarView.isHidden = true
        
        let audioMicImage = UIImage(named: audioMicImageName, in: Bundle(for: type(of: self)), compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
        micImageView.image = audioMicImage
        micImageView.tintColor = .red
    }
    
    public func addCustomConstraintToCellView(paddingSize: CGFloat) {
        contentViewTopConstraint.constant = paddingSize
        contentViewBottomConstraint.constant = paddingSize
        contentViewLeadingConstraint.constant = paddingSize
        contentViewTrailingConstraint.constant = paddingSize
    }
    
    public func addCornerRadius(size: CGFloat) {
        speakerView.layer.cornerRadius = size
    }
    
    public func setDefaultAvatarTitle(text: String, fontSize: Double) {
        defaultAvatarLabel.text = text
        defaultAvatarLabel.font = defaultAvatarLabel.font.withSize(fontSize)
    }
    
    public func setupDefaultAvatarView() {
        var newConstraint: NSLayoutConstraint
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            newConstraint = defaultAvatarViewWidth.constraintWithMultiplier(0.32)
        default:
            newConstraint = defaultAvatarViewWidth.constraintWithMultiplier(0.61)
        }
        defaultAvatarViewWidth.isActive = false
        defaultAvatarViewWidth = newConstraint
        defaultAvatarViewWidth.isActive = true
        layoutIfNeeded()
        defaultAvatarView.layer.cornerRadius = defaultAvatarView.frame.width / 2
    }
    
    public func showDefaultAvatar(bool: Bool) {
        defaultAvatarView.isHidden = !bool
    }
    
    public func showSpeakerAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.speakerView.layer.borderWidth = 2
            self.speakerView.layer.borderColor = UIColor(red: 0.17, green: 0.64, blue: 0.44, alpha: 1).cgColor
        } completion: { _ in
            self.fadeSpeakerAnimation()
        }
    }
    
    private func fadeSpeakerAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.speakerView.layer.borderWidth = 0
        }
    }

}
