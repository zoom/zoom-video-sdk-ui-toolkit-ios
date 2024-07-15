//
//  StatsBlockCell.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit

final class StatsBlockCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statsTextView: UITextView!
    
    struct ViewModel {
        let title: String
        let statsText: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
            statsTextView.text = viewModel?.statsText
        }
    }
}
