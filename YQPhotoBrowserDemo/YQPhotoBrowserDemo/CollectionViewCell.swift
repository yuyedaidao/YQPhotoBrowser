//
//  CollectionViewCell.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/14.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit
import Kingfisher

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: AnimatedImageView!

    var url: String! {
        didSet {
            imgView.stopAnimating()
            imgView.kf.setImage(with: URL(string: url), placeholder: nil, options: [.transition(.flipFromTop(0.3))], progressBlock: nil) { (image, error, type, url) in
            }
            
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
