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
    var url: URL? {
        didSet {
            if oldValue != url {
                guard let url = url else {
                    playerItem = nil
                    return
                }
                playerItem = AVPlayerItem(url: url)
            }
        }
    }
    weak var delegate: YQPhotoCellDelegate?
    private var playButton: UIButton!
    var player = AVPlayer()
    private var playerItem: AVPlayerItem?
    lazy var playerView: UIView = {
        return YQPlayerView(frame: bounds, player: player)
    }()

    override init(frame: CGRect) {
        playButton = UIButton(type: .custom)
        super.init(frame: frame)
        addSubview(self.playerView)
        playButton.yq.then { (button) in
            button.setImage(UIImage(named: "play"), for: .normal)
            button.setImage(UIImage(named: "pause"), for: .selected)
            button.addTarget(self, action: #selector(playOrPauseAction(_:)), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            addSubview(button)
        }
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapAction(gesture:)))
        oneTap.numberOfTapsRequired = 1
        addGestureRecognizer(oneTap)

        NotificationCenter.default.yq.then { (center) in
            center.addObserver(self, selector: #selector(playerItemAction(_:)), name: .AVPlayerItemNewErrorLogEntry, object: nil)
            center.addObserver(self, selector: #selector(playerItemAction(_:)), name: .AVPlayerItemNewAccessLogEntry, object: nil)
            center.addObserver(self, selector: #selector(playerItemAction(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            center.addObserver(self, selector: #selector(playerItemAction(_:)), name: .AVPlayerItemTimeJumped, object: nil)
            center.addObserver(self, selector: #selector(playerItemAction(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
            center.addObserver(self, selector: #selector(playerItemAction(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerView.frame = self.bounds
        self.playButton.center = self.playerView.center
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
            if player.currentItem != playerItem {
                player.replaceCurrentItem(with: playerItem)
            }
            player.play()
            delegate?.videoCell(self, replacePlayer: player)
            playButton.isSelected = true
        }
    }
}

// MARK: - Observer
extension YQPhotoVideoCell {

    @objc func playerItemAction(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, self.player.currentItem == item else {return}
        switch notification.name {
        case .AVPlayerItemDidPlayToEndTime:
            player.seek(to: kCMTimeZero)
            playButton.isSelected = false
        default:
            debugPrint(notification.name)
            break
        }
    }
}
