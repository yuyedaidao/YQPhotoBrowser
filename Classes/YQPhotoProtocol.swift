//
//  YQPhotoProtocol.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/15.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation
import UIKit

protocol YQPhotoCellCompatible where Self: UICollectionViewCell {
    var url: URL? {get set}
    var delegate: YQPhotoCellDelegate? {get set}
}

protocol YQPhotoCellDelegate: NSObjectProtocol {
    func clickOnce(_ cell: YQPhotoCellCompatible)
}
