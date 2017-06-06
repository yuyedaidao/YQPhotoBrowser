//
//  YQPhotoCell.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import Kingfisher

func yq_clamp<T: Comparable>(_ x: T, _ low: T, _ high: T) -> T {
    return min(max(x, low), high)
}

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

protocol YQPhotoCellDelegate {
    func isPresented() -> Bool
    func shouldDismiss()
}

class YQPhotoCell: UICollectionViewCell {
    var delegate: YQPhotoCellDelegate?
    var beginPoint = CGPoint.zero
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
                imageView.image = UIImage(contentsOfFile: u.absoluteString)
                self.resizeSubviews()
            } else {
                self.progressLayer.strokeEnd = 0
                self.progressLayer.position = CGPoint(x: self.width / 2, y: self.height / 2)
                self.progressLayer.isHidden = false
            
                imageView.kf.setImage(with: u, placeholder: nil, options: [.backgroundDecode], progressBlock: { (receivedSize: Int64, totalSize: Int64) in
                    self.progressLayer.progress = Double(receivedSize) / Double(totalSize)
                }, completionHandler: { (image, error, cacheType, url) in
                    self.imageView.image = image
                    self.progressLayer.isHidden = true
                    self.resizeSubviews()
                })
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
        scrollView.isMultipleTouchEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(gesture:)))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
        
    }
    
    override func prepareForReuse() {
        scrollView.setZoomScale(1, animated: false)
    }
    
    
    private func resizeSubviews() {
        
        imageContainerView.frame.origin = CGPoint.zero
        imageContainerView.width = scrollView.width
        guard let image = imageView.image else {
            return
        }
        if image.size.height / image.size.width > scrollView.height / scrollView.width {
            imageContainerView.height = floor(image.size.height / image.size.width * scrollView.width)
        } else {
            var height = image.size.height / image.size.width * scrollView.width
            if height < 1 || height.isNaN {
                height = scrollView.height
            }
            imageContainerView.height = floor(height)
            imageContainerView.center = CGPoint(x: imageContainerView.center.x, y: scrollView.height / 2)
        }
        if (imageContainerView.height > scrollView.height && imageContainerView.height - scrollView.height <= 1) {
            imageContainerView.height = scrollView.height;
        }
        scrollView.contentSize = CGSize(width: scrollView.width, height: max(imageContainerView.height, scrollView.height))
        scrollView.scrollRectToVisible(scrollView.bounds, animated: false)
        if (imageContainerView.height <= scrollView.height) {
            scrollView.alwaysBounceVertical = false;
        } else {
            scrollView.alwaysBounceVertical = true;
        }
        imageView.frame = imageContainerView.bounds
        scrollView.maximumZoomScale = 3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Action

extension YQPhotoCell {
    func doubleTapAction(gesture: UITapGestureRecognizer) {
        if (scrollView.zoomScale > 1) {
           scrollView.setZoomScale(1, animated: true)
        } else {
            let location = gesture.location(in: imageView)
            let xSize = scrollView.width / scrollView.maximumZoomScale
            let ySize = scrollView.height / scrollView.maximumZoomScale
            scrollView.zoom(to: CGRect(x: location.x - xSize / 2, y: location.y - ySize / 2, width: xSize, height: ySize), animated: true)
        }

    }
    
//    func panAction(gesture: UIPanGestureRecognizer) {
//        
//        switch gesture.state {
//        case .began:
//            if let del = delegate, del.isPresented() {
//                beginPoint = gesture.location(in: self)
//            } else {
//                beginPoint = CGPoint.zero
//            }
//        case .changed:
//            guard !beginPoint.equalTo(CGPoint.zero) else {
//                return
//            }
//            let p = gesture.location(in: self)
//            let deltaY = p.y - beginPoint.y
//            scrollView.frame.origin.y = deltaY
//            var alpha = (160 - fabs(deltaY) + 50) / 160
//            alpha = yq_clamp(alpha, 0, 1)
//            UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear], animations: { 
//                
//            }, completion: nil)
//            
//        case .ended:
//            guard !beginPoint.equalTo(CGPoint.zero) else {
//                return
//            }
//            let v = gesture.velocity(in: self)
//            let p = gesture.location(in: self)
//            let deltaY = p.y - beginPoint.y
//            if fabs(v.y) > 1000 || fabs(p.y) > 120 {
//                let moveToTop = v.y < -50 && deltaY < 0
//                var vy = fabs(v.y)
//                if vy < 1 {
//                    vy =  1
//                }
//                var duration = (moveToTop ? scrollView.frame.maxY : self.bounds.height - scrollView.frame.minY) / vy
//                duration *= 0.8
//                duration = yq_clamp(duration, 0.05, 0.3)
//                UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveLinear, .beginFromCurrentState], animations: { 
//                    if moveToTop {
//                        self.scrollView.frame.origin.y = 0
//                    } else {
//                        self.scrollView.frame.origin.y = self.bounds.height
//                    }
//                }, completion: { (finished) in
//                    guard let del = self.delegate else {
//                        return
//                    }
//                    del.shouldDismiss()
//                })
//            }
//        case .cancelled:
//            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveLinear, .beginFromCurrentState], animations: {
//                self.scrollView.frame.origin.y = 0
//            }, completion: { (finished) in
//                
//            })
//        default:
//            break
//        }
//    }
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
