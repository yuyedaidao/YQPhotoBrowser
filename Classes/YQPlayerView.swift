//
//  YQPlayerView.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/19.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit
import AVFoundation

class YQPlayerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    } 
    */
    weak var player: AVPlayer? {
        didSet {
            isDisplayed = false
            playerLayer.player = player
        }
    }
    private var playerLayer: AVPlayerLayer!
    private var isDisplayed = false
    var thumbnail: UIImage? {
        didSet {
            playerLayer.contents = thumbnail?.cgImage
        }
    }
    init(frame: CGRect = CGRect.zero, player: AVPlayer?) {
        self.player = player
        let layer = AVPlayerLayer(player: player)
        layer.contentsGravity = CALayerContentsGravity.resizeAspect
        self.playerLayer = layer
        super.init(frame: frame)
        layer.frame = bounds
        self.layer.addSublayer(layer)
        self.clipsToBounds = true
        layer.addObserver(self, forKeyPath: "readyForDisplay", options: [.new], context: nil)
    }

    deinit {
        playerLayer?.removeObserver(self, forKeyPath: "readyForDisplay")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

extension YQPlayerView {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "readyForDisplay" else {
            return
        }
    }
}
