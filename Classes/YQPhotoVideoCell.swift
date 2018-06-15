//
//  YQPhotoVideoCell.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/15.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit
import AVFoundation

class YQPhotoVideoCell: UICollectionViewCell, YQPhotoCellCompatible {
    var url: URL?
    weak var delegate: YQPhotoCellDelegate?
    var playButton: UIButton!
    var player = AVPlayer()
    var playItem: AVPlayerItem?

    lazy var playerView: UIView = {
        let view =  UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        view.layer.insertSublayer(playerLayer, at: 0)
        return view
    }()

    override init(frame: CGRect) {
        playButton = UIButton(type: .custom)
        super.init(frame: frame)
        addSubview(self.playerView)
        playButton.setImage(UIImage(named: "play"), for: .normal)
        playButton.setImage(UIImage(named: "pause"), for: .selected)
        playButton.addTarget(self, action: #selector(playOrPauseAction(_:)), for: .touchUpInside)
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapAction(gesture:)))
        oneTap.numberOfTapsRequired = 1
        addGestureRecognizer(oneTap)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        self.playerView.frame = self.bounds
    }

    @objc func oneTapAction(gesture: UITapGestureRecognizer) {
        delegate?.clickOnce(self)

    }

    @objc func playOrPauseAction(_ sender: UIButton) {
        if playButton.isSelected {
            //点击后暂停
            player.pause()
            playButton.isSelected = false
        } else {
            if player.currentItem == nil {
                let item = AVPlayerItem(url: url!)
                player.replaceCurrentItem(with: item)
            }
            player.play()
            playButton.isSelected = true
        }

    }
}
