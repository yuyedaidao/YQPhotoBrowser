//
//  CollectionViewCell.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/14.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit
import YQKingfisher

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: AnimatedImageView!

    var url: String! {
        didSet {
            imgView.stopAnimating()
            imgView.kf.setImage(with: URL(string: url))
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.runLoopMode = RunLoop.Mode.default
        imgView.autoPlayAnimatedImage = false;
    }
}
