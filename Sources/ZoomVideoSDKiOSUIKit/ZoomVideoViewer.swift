//
//  ZoomVideoViewer.swift
//  
//
//  Created by Boon Jun Tan on 25/4/23.
//

import UIKit
import ZoomVideoSDK

public class ZoomVideoViewer: UIView {
    
    internal var connectionData: ZoomConnectionData!
    
    public weak var delegate: ZoomVideoViewerDelegate?
    
    public internal(set) var zoomVideoViewerSettings: ZoomVideoViewerSettings
    
    public init(
        connectionData: ZoomConnectionData,
        zoomVideoViewerSettings: ZoomVideoViewerSettings = ZoomVideoViewerSettings(), delegate: ZoomVideoViewerDelegate? = nil
    ) {
        self.connectionData = connectionData
        self.zoomVideoViewerSettings = zoomVideoViewerSettings
        self.delegate = delegate
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        self.zoomVideoViewerSettings = ZoomVideoViewerSettings()
        super.init(coder: coder)
    }
    
}
