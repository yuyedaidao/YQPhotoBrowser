//
//  TableViewCell.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import Kingfisher

class TableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    var url: String! {
        didSet {
            imgView.kf.setImage(with: URL(string: url), placeholder: nil, options: [.transition(.flipFromTop(0.3))], progressBlock: nil) { (image, error, type, url) in
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
