//
//  YQPhotoBundle.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/26.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation

class YQPhotoBundle: Bundle {
    static let shared = YQPhotoBundle()
    private init() {
        let path = Bundle(for:  YQPhotoBrowser.classForCoder()).resourcePath?.appending("/YQPhotoBrowser.bundle")
        super.init(path: path!)!
    }
}
