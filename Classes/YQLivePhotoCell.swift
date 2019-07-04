//
//  YQLivePhotoCell.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2019/1/30.
//  Copyright © 2019 Wang. All rights reserved.
//

import UIKit
import PhotosUI
import Photos
import Kingfisher

/// 暂时只支持本地LivePhoto

@available(iOS 9.1, *)
class YQLivePhotoCell: UICollectionViewCell, YQPhotoCellCompatible {
    var resource: YQPhotoResource? {
        didSet {
            guard let resource = resource, resource.type == .livePhoto else {
                self.livePhotoView.livePhoto = nil
                return
            }
            let urls = [resource.url!, resource.additionalUrl!]
            if let thumbnail = resource.thumbnail as? UIImage {
                fetchLivePhoto(placeholder: thumbnail, fileURLs: urls)
            } else if let thumbnail = resource.thumbnail as? URL {
                KingfisherManager.shared.downloader.downloadImage(with: thumbnail, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
                    guard let image = image else {
                        self.fetchLivePhoto(placeholder: nil, fileURLs: urls)
                        return
                    }
                    self.fetchLivePhoto(placeholder: image, fileURLs: urls)
                }
            }
            KingfisherManager.shared.downloader.downloadImage(with: resource.url!, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
                /// 这是本地加载，较快
                guard url == self.resource?.url else {return}
                self.coverImage = image
            }
        }
    }
    
    /// 静止时显示的图片，主要用在拖动消失动画中
    var coverImage: UIImage?
    var requestID: PHLivePhotoRequestID?
    var delegate: YQPhotoCellDelegate?
    let livePhotoView: PHLivePhotoView = PHLivePhotoView(frame: CGRect.zero)
    
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    override init(frame: CGRect) {
        super.init(frame: frame)
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(livePhotoView)
        widthConstraint = livePhotoView.widthAnchor.constraint(equalToConstant: frame.width / 2)
        widthConstraint.isActive = true
        heightConstraint = livePhotoView.heightAnchor.constraint(equalToConstant: frame.height)
        heightConstraint.isActive = true
        livePhotoView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        livePhotoView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        livePhotoView.delegate = self
        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapAction(gesture:)))
        oneTap.numberOfTapsRequired = 1
        addGestureRecognizer(oneTap)
        oneTap.require(toFail: livePhotoView.playbackGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func fetchLivePhoto(placeholder: UIImage?, fileURLs: [URL]) {
        if let requestID = self.requestID {
            PHLivePhoto.cancelRequest(withRequestID: requestID)
        }
        requestID = PHLivePhoto.request(withResourceFileURLs: fileURLs, placeholderImage: placeholder, targetSize: CGSize.zero, contentMode: PHImageContentMode.aspectFit, resultHandler: { (livePhoto, info) in
            self.livePhotoView.livePhoto = livePhoto
            guard let size = livePhoto?.size else {
                return
            }
            DispatchQueue.main.async {
                self.resizeLivePhotoView(fit: size)
            }
        })
    }
    
    func resizeLivePhotoView(fit size: CGSize) {
        let screenSize = UIScreen.main.bounds.size
        let height: CGFloat
        let width: CGFloat
        if size.height / size.width > screenSize.height / screenSize.width {
            height = screenSize.height
            width = height * size.width / size.height
        } else {
            width = screenSize.width
            height = width * size.height / size.width
        }
        widthConstraint.constant = width
        heightConstraint.constant = height
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
}

@available(iOS 9.1, *)
extension YQLivePhotoCell {
    @objc func oneTapAction(gesture: UITapGestureRecognizer) {
        delegate?.clickOnce(self)
    }
}
@available(iOS 9.1, *)
extension YQLivePhotoCell: PHLivePhotoViewDelegate {
    
}

