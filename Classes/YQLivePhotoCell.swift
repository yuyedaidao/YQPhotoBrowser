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
class YQLivePhotoCell: UICollectionViewCell, YQPhotoCellCompatible {
    var resource: YQPhotoResource? {
        didSet {
            guard let resource = resource, resource.isLivePhoto else {
                self.livePhotoView.livePhoto = nil
                return
            }
            let urls = [resource.url!, resource.additionalUrl!]
            if let thumbnail = resource.thumbnail as? UIImage {
                fetchLivePhoto(placeholder: thumbnail, fileURLs: urls)
            } else if let thumbnail = resource.thumbnail as? URL {
                KingfisherManager.shared.downloader.downloadImage(with: thumbnail, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
                    guard let image = image else {
                        self.fetchLivePhoto(placeholder: UIImage(), fileURLs: urls)
                        return
                    }
                    self.fetchLivePhoto(placeholder: image, fileURLs: urls)
                }
            }
            
        }
    }
    var requestID: PHLivePhotoRequestID?
    var delegate: YQPhotoCellDelegate?
    let livePhotoView: PHLivePhotoView = PHLivePhotoView(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        livePhotoView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func fetchLivePhoto(placeholder: UIImage, fileURLs: [URL]) {
        if let requestID = self.requestID {
            PHLivePhoto.cancelRequest(withRequestID: requestID)
        }
        requestID = PHLivePhoto.request(withResourceFileURLs: fileURLs, placeholderImage: placeholder, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, resultHandler: { (livePhoto, info) in
            self.livePhotoView.livePhoto = livePhoto
        })
    }
    
}

extension YQLivePhotoCell: PHLivePhotoViewDelegate {
    
}

