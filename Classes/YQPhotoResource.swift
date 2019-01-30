//
//  YQPhotoResource.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/19.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit

public protocol YQThumbnailResource {

}

extension URL: YQThumbnailResource {}
extension UIImage: YQThumbnailResource {}

public class YQPhotoResource {
    var url: URL?
    var thumbnail: YQThumbnailResource?
    var isLivePhoto: Bool = false
    var additionalUrl: URL?
    init(url: URL?, thumbnail: YQThumbnailResource?, isLivePhoto: Bool = false, additionalUrl: URL? = nil) {
        self.url = url
        self.thumbnail = thumbnail
        self.isLivePhoto = isLivePhoto
        if isLivePhoto {
            assert(additionalUrl != nil, "LivePhoto必须提供相应的视频资源地址")
            self.additionalUrl = additionalUrl
        }
    }
}
