//
//  YQPhotoProtocol.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/15.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol YQPhotoCellCompatible where Self: UICollectionViewCell {
    var resource: YQPhotoResource? {get set}
    var delegate: YQPhotoCellDelegate? {get set}
}

protocol YQPhotoCellDelegate: NSObjectProtocol {
    func clickOnce(_ cell: YQPhotoCellCompatible)
    func videoCell(_ cell: YQPhotoCellCompatible, replacePlayer player: AVPlayer?)
}

extension YQPhotoCellDelegate {
    func videoCell(_ cell: YQPhotoCellCompatible, replacePlayer player: AVPlayer?) {
        debugPrint("videoCell(_ cell: YQPhotoCellCompatible, replacePlayer player: AVPlayer?) 空实现")
    }
}
