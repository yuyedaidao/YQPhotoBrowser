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
//    public static func == (lhs: YQPhotoResource, rhs: YQPhotoResource) -> Bool {
//
//        return lhs.url == rhs.url && lhs.thumbnail == rhs.thumbnail
//    }
    var url: URL?
    var thumbnail: YQThumbnailResource?

    init(url: URL?, thumbnail: YQThumbnailResource?) {
        self.url = url
        self.thumbnail = thumbnail
    }
}
