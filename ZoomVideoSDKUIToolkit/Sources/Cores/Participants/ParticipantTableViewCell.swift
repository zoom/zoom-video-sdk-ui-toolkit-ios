//
//  ParticipantTableViewCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ctaBtn: UIButton!
    @IBOutlet weak var ctaBtn2: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarLabel.layer.cornerRadius = 8
        avatarLabel.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            nameLabel.textColor = UIColor(red: 0, green: 82/255, blue: 217/255, alpha: 1)
            self.contentView.backgroundColor = UIColor(red: 242/255, green: 243/255, blue: 1, alpha: 1)
        } else {
            nameLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
            self.contentView.backgroundColor = .white
        }
    }
    
    @IBAction func onClickCTABtn(_ sender: UIButton) {
        // Future Development if needed
    }
    
    @IBAction func onClickCTABtn2(_ sender: Any) {
        // Future Development if needed
    }
    
    public func setCell(avatarName: String? = nil, avatarIcon: String? = nil, name: String, ctaImage: UIImage? = nil, ctaImageColor: UIColor? = nil, ctaImage2: UIImage? = nil, ctaImage2Color: UIColor? = nil, cta: (() -> ())? = nil, cta2: (() -> ())? = nil) {
        if avatarName != nil {
            avatarLabel.text = avatarName
            avatarLabel.isHidden = false
            avatarImageView.isHidden = true
        } else {
            avatarLabel.isHidden = true
            avatarImageView.isHidden = false
            avatarImageView.image = UIImage(named: avatarIcon ?? "", in: Bundle(for: type(of: self)), compatibleWith: .none)
            avatarImageView.contentMode = .center
            avatarImageView.tintColor = .white
            avatarImageView.backgroundColor = UIColor(red: 0, green: 82/255, blue: 217/255, alpha: 1)
        }
        nameLabel.text =  name
        ctaBtn.setImage(ctaImage, for: .normal)
        ctaBtn.tintColor = ctaImageColor
        ctaBtn.backgroundColor = .clear
        ctaBtn2.setImage(ctaImage2, for: .normal)
        ctaBtn2.tintColor = ctaImage2Color
        ctaBtn2.backgroundColor = .clear
    }
    
    public func setCTABtn(ctaImage: UIImage, ctaImageColor: UIColor) {
        ctaBtn.setImage(ctaImage, for: .normal)
        ctaBtn.tintColor = ctaImageColor
    }
    
    public func setCTABtn2(ctaImage2: UIImage, ctaImage2Color: UIColor) {
        ctaBtn2.setImage(ctaImage2, for: .normal)
        ctaBtn2.tintColor = ctaImage2Color
    }
}
