//
//  StatisticsVC.swift
//  ZoomVideoSDKUIToolkit
//
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import UIKit
import ZoomVideoSDK

class StatisticsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var audioStatsInfo: ZoomVideoSDKSessionAudioStatisticInfo? = nil
    private var videoStatsInfo: ZoomVideoSDKSessionASVStatisticInfo? = nil
    private var statsSections: [Section] = []

    public init() {
        super.init(
            nibName: String(describing: StatisticsVC.self),
            bundle: Bundle(for: StatisticsVC.self)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchStats()
        setupUI()
    }
    
    private func setupUI() {
        collectionView.register(UINib(nibName: String(describing: StatsBlockCell.self),
                                      bundle: Bundle(for: StatsBlockCell.self)),
                                forCellWithReuseIdentifier: "\(StatsBlockCell.self)")
        collectionView.register(StatsSectionHeaderView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: "\(StatsSectionHeaderView.self)")
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/CGFloat(self.statsSections.count)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(35))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: "header", alignment: .top)
        section.boundarySupplementaryItems = [headerItem]

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }
    
    private func fetchStats() {
        self.audioStatsInfo = ZoomVideoSDK.shareInstance()?.getSession()?.getAudioStatisticInfo()
        if let audioStats = self.audioStatsInfo {
            var audioSendStatsText = ""
            audioSendStatsText += "\u{2022} frequency: \(audioStats.sendFrequency)\n"
            audioSendStatsText += "\u{2022} jitter: \(audioStats.sendJitter)\n"
            audioSendStatsText += "\u{2022} latency: \(audioStats.sendLatency)\n"
            audioSendStatsText += "\u{2022} packet loss average: \(audioStats.sendPacketLossAvg)\n"
            audioSendStatsText += "\u{2022} packet loss max: \(audioStats.sendPacketLossMax)"
            let audioSendItem = Section.Item(title: "Send", stats: audioSendStatsText)
            
            var audioReceiveStatsText = ""
            audioReceiveStatsText += "\u{2022} frequency: \(audioStats.recvFrequency)\n"
            audioReceiveStatsText += "\u{2022} jitter: \(audioStats.recvJitter)\n"
            audioReceiveStatsText += "\u{2022} latency: \(audioStats.recvLatency)\n"
            audioReceiveStatsText += "\u{2022} packet loss average: \(audioStats.recvPacketLossAvg)\n"
            audioReceiveStatsText += "\u{2022} packet loss max: \(audioStats.recvPacketLossMax)"
            let audioReceiveItem = Section.Item(title: "Receive", stats: audioReceiveStatsText)
            
            self.statsSections.append(Section(title: "Audio", items: [audioSendItem, audioReceiveItem]))
        }
        
        self.videoStatsInfo = ZoomVideoSDK.shareInstance()?.getSession()?.getVideoStatisticInfo()
        if let videoStats = self.videoStatsInfo {
            var videoSendStatsText = ""
            videoSendStatsText += "\u{2022} fps: \(videoStats.sendFps)\n"
            videoSendStatsText += "\u{2022} jitter: \(videoStats.sendJitter)\n"
            videoSendStatsText += "\u{2022} latency: \(videoStats.sendLatency)\n"
            videoSendStatsText += "\u{2022} packet loss average: \(videoStats.sendPacketLossAvg)\n"
            videoSendStatsText += "\u{2022} packet loss max: \(videoStats.sendPacketLossMax)\n"
            videoSendStatsText += "\u{2022} height/width: \(videoStats.sendFrameHeight)/\(videoStats.sendFrameWidth)"
            let videoSendItem = Section.Item(title: "Send", stats: videoSendStatsText)

            var videoReceiveStatsText = ""
            videoReceiveStatsText += "\u{2022} fps: \(videoStats.recvFps)\n"
            videoReceiveStatsText += "\u{2022} jitter: \(videoStats.recvJitter)\n"
            videoReceiveStatsText += "\u{2022} latency: \(videoStats.recvLatency)\n"
            videoReceiveStatsText += "\u{2022} packet loss average: \(videoStats.recvPacketLossAvg)\n"
            videoReceiveStatsText += "\u{2022} packet loss max: \(videoStats.recvPacketLossMax)\n"
            videoReceiveStatsText += "\u{2022} height/width: \(videoStats.recvFrameHeight)/\(videoStats.recvFrameWidth)"
            let videoReceiveItem = Section.Item(title: "Receive", stats: videoReceiveStatsText)

            self.statsSections.append(Section(title: "Video", items: [videoSendItem, videoReceiveItem]))
        }
    }
}

extension StatisticsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    struct Section {
        struct Item {
            let title: String
            let stats: String
        }
        
        let title: String
        let items: [Item]
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.statsSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(StatsBlockCell.self)", for: indexPath) as? StatsBlockCell else {
            return UICollectionViewCell()
        }

        let statsBlock = self.statsSections[indexPath.section].items[indexPath.item]
        cell.viewModel = StatsBlockCell.ViewModel(title: statsBlock.title, statsText: statsBlock.stats)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(StatsSectionHeaderView.self)", for: indexPath) as? StatsSectionHeaderView else {
            return StatsSectionHeaderView()
        }
        
        headerView.viewModel = StatsSectionHeaderView.ViewModel(title: self.statsSections[indexPath.section].title)
        return headerView
    }

}

final class StatsSectionHeaderView: UICollectionReusableView {
    struct ViewModel {
        let title: String
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    var viewModel: ViewModel? {
        didSet {
            label.text = viewModel?.title
        }
    }
}
