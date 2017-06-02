//
//  YQPhotoCell.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import Kingfisher

let YQProgressLayerSize: CGFloat = 40.0
class YQProgressLayer: CAShapeLayer {
    var progress: Double! {
        didSet {
            self.strokeEnd = CGFloat(max(0.0, min(progress, 1.0)))
        }
    }
    class func create() -> YQProgressLayer{
        let layer = YQProgressLayer()
        layer.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 40, height: YQProgressLayerSize))
        layer.cornerRadius = YQProgressLayerSize / 2
        layer.backgroundColor = UIColor(white: 0, alpha: 0.5).cgColor
        let path = UIBezierPath(roundedRect: layer.bounds.insetBy(dx: 7, dy: 7), cornerRadius: YQProgressLayerSize / 2 - 7)
        layer.path = path.cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 4
        layer.lineCap = kCALineCapRound
        layer.strokeStart = 0
        layer.strokeEnd = 0
        layer.isHidden = true
        return layer
    }
}

class YQPhotoCell: UICollectionViewCell {
    var url: URL? {
        willSet {
            guard newValue != url else {
                return
            }
            scrollView.zoomScale = 1
            scrollView.maximumZoomScale = 1
            guard let u = newValue else {
                return
            }
            
            if u.isFileURL {
                
            } else {
                
            }
        }
    }
    let scrollView: UIScrollView
    let imageContainerView: UIView
    let imageView: UIImageView
    lazy var progressLayer: YQProgressLayer = {
        let layer = YQProgressLayer.create()
        self.layer.addSublayer(layer)
        return layer
    }()
    
    override init(frame: CGRect) {
        scrollView = UIScrollView()
        imageContainerView = UIView()
        imageView = UIImageView()
        super.init(frame: frame)
        scrollView.frame = bounds
        scrollView.delegate = self
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 3
        scrollView.isMultipleTouchEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YQPhotoCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height) * 0.5 : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
