//
//  YQPhotoImageView.swift
//  Pods
//
//  Created by Wang on 2017/6/7.
//
//

import UIKit
import Kingfisher

protocol YQPhotoImageViewProxy where Self: UIView {
    var image: UIImage? {get}
}

extension UIImageView: YQPhotoImageViewProxy {}

class YQPhotoImageView: UIView, YQPhotoImageViewProxy {

    let imgView = AnimatedImageView()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var image: UIImage? {
        didSet {
            imgView.image = image
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(image: UIImage?) {
        super.init(frame: CGRect.zero)
        self.image = image
        self.commonInit()
    }
    
    func commonInit() {
        imgView.frame = self.bounds
        imgView.image = image
        clipsToBounds = true
        addSubview(imgView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let img = image else {
            imgView.frame = self.bounds
            return
        }
        let height = floor(img.size.height / img.size.width  * self.bounds.width)
        imgView.frame = CGRect(x: 0, y: self.bounds.size.height / 2 - height / 2, width: self.bounds.width, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
