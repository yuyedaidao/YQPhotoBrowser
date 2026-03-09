//
//  YQPhotoBundle.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/26.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation

enum YQPhotoBundle {
    static var shared: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        let currentBundle = Bundle(for: YQPhotoBrowser.self)
        guard let resourcePath = currentBundle.resourcePath,
              let resourceBundle = Bundle(path: resourcePath.appending("/YQPhotoBrowser.bundle")) else {
            return currentBundle
        }
        return resourceBundle
#endif
    }
}
