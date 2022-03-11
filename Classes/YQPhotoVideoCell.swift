//
//  YQPhotoVideoCell.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/15.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit
import AVFoundation
import YQKingfisher

class NotificationObserver: NSObject {}

class YQPhotoVideoCell: UICollectionViewCell, YQPhotoCellCompatible {
    var resource: YQPhotoResource? {
        didSet {
            guard let resource = self.resource else {return}
            let identifier = resource.url?.absoluteString
            if identifier != self.identifier {
                self.identifier = identifier
                player = AVPlayer()
                playerView.player = player
                playerItem = AVPlayerItem(url: resource.url!)
                if let thumbnail = resource.thumbnail as? UIImage {
                    playerView.thumbnail = thumbnail
                } else if let thumbnail = resource.thumbnail as? URL {
                    KingfisherManager.shared.retrieveImage(with: thumbnail, completionHandler: {[weak self] (result) in
                        guard let self = self else {return}
                        switch result {
                        case .success(let value):
                            self.playerView.thumbnail = value.image
                        default:
                            break
                        }
                    })
                }
            }
        }
    }
    private var identifier: String?
    weak var delegate: YQPhotoCellDelegate?
    private var playButton: UIButton!
    var player = AVPlayer()
    private var playerItem: AVPlayerItem?
    private var hidePlayButtonTask: DispatchWorkItem?
    
    lazy var playerView: YQPlayerView = {
        return YQPlayerView(frame: bounds, player: player)
    }()

    override init(frame: CGRect) {
        playButton = UIButton(type: .custom)
        super.init(frame: frame)
        addSubview(self.playerView)
        playButton.yq.then { (button) in
            button.setImage("yq_pb_play".bundleImage, for: .normal)
            button.setImage("yq_pb_pause".bundleImage, for: .selected)
            button.addTarget(self, action: #selector(playOrPauseAction(_:)), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            addSubview(button)
        }
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapAction(gesture:)))
        oneTap.numberOfTapsRequired = 1
        addGestureRecognizer(oneTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        oneTap.require(toFail: doubleTap)

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.pause()
    }

    public func play() {
        guard let item = playerItem else {return}
        if player.currentItem == item {
            player.play()
        } else {
            player.replaceCurrentItem(with: item)
            player.play()
        }
        delegate?.videoCell(self, replacePlayer: player)
        playButton.isSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            guard self.playButton.isSelected else {
                self.playButton.alpha = 1
                return
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.playButton.alpha = 0
            }, completion: nil)
        }
    }

    public func pause() {
        player.pause()
        playButton.isSelected = false
        self.playButton.alpha = 1
        if let task = self.hidePlayButtonTask {
            task.cancel()
        }
    }

    @objc func oneTapAction(gesture: UITapGestureRecognizer) {
        delegate?.clickOnce(self)
    }
    
    @objc func doubleTapAction(gesture: UITapGestureRecognizer) {
        guard self.playButton.isSelected else {
            return
        }
        self.playButton.alpha = 1
        if let task = self.hidePlayButtonTask {
            task.cancel()
        }
        
        self.hidePlayButtonTask = createHideTask()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: self.hidePlayButtonTask!)
    }

    @objc func playOrPauseAction(_ sender: UIButton) {
        if playButton.isSelected {
            //点击后暂停
            pause()
        } else {
            play()
        }
    }

    func createHideTask() -> DispatchWorkItem {
        return DispatchWorkItem(block: {
            guard self.playButton.isSelected else {
                self.playButton.alpha = 1
                return
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.playButton.alpha = 0
            }, completion: nil)
        })
    }
}

// MARK: - Observer
extension YQPhotoVideoCell {

    @objc func playerItemAction(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, self.player.currentItem == item else {return}
        switch notification.name {
        case .AVPlayerItemDidPlayToEndTime:
            player.seek(to: CMTime.zero)
            playButton.isSelected = false
            playButton.alpha = 1
            if let task = self.hidePlayButtonTask {
                task.cancel()
            }
        default:
            debugPrint(notification.name)
            break
        }
    }
}
