//
//  YQPhotoThen.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/13.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation

struct YQPhotoThen<T> {
    private let base: T
    init(_ base: T) {
        self.base = base
    }

    @discardableResult
    func then(_ block: (T) -> Void) -> YQPhotoThen {
        block(base)
        return self
    }

    @discardableResult
    func done(_ block: ((T) -> Void)? = nil) -> T {
        block?(base)
        return base
    }
}

protocol YQPhotoThenCompatible {
    associatedtype T
    var yq: YQPhotoThen<T> {get}
}

extension YQPhotoThenCompatible {
    var yq: YQPhotoThen<Self> {
        return YQPhotoThen(self)
    }
}

extension NSObject: YQPhotoThenCompatible {}
