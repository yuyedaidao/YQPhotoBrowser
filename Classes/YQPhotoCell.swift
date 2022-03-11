//
//  YQPhotoCell.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import YQKingfisher

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
        layer.lineCap = CAShapeLayerLineCap.round
        layer.strokeStart = 0
        layer.strokeEnd = 0
        layer.isHidden = true
        return layer
    }
}

class YQPhotoCell: UICollectionViewCell, YQPhotoCellCompatible {

    var beginPoint = CGPoint.zero
    weak var delegate: YQPhotoCellDelegate?
    var resource: YQPhotoResource? {
        didSet {
            scrollView.zoomScale = 1
            scrollView.maximumZoomScale = 1
            guard let resource = self.resource, let url = resource.url else {
                return
            }
            if let thumbnail = resource.thumbnail as? UIImage {
                imageView.image = thumbnail
                resizeSubviews()
            } else if let thumbnail = resource.thumbnail as? URL {
                imageView.kf.setImage(with: thumbnail, placeholder: nil, options: nil, progressBlock: nil) {[weak self] (_) in
                    guard let self = self else {return}
                    self.resizeSubviews()
                }
            }
            var options: KingfisherOptionsInfo = [.backgroundDecode]
            if url.isFileURL {
                options.append(.forceRefresh)
                imageView.kf.cancelDownloadTask()
                imageView.kf.setImage(with: url, placeholder: nil, options: options, progressBlock: nil) {[weak self] (_) in
                    guard let self = self else {return}
                    self.resizeSubviews()
                }
            } else {
                progressLayer.strokeEnd = 0
                progressLayer.position = CGPoint(x: self.width / 2, y: self.height / 2)
                progressLayer.isHidden = false
                imageView.kf.setImage(with: url, placeholder: imageView.image, options: options) {[weak self] (receivedSize: Int64, totalSize: Int64) in
                    guard let self = self else {return}
                    self.progressLayer.progress = Double(receivedSize) / Double(totalSize)
                } completionHandler: {[weak self] (_) in
                    guard let self = self else {return}
                    self.progressLayer.isHidden = true
                    self.resizeSubviews()
                }
            }
        }
    }
    let scrollView: UIScrollView
    let imageContainerView: UIView
    let imageView: AnimatedImageView
    lazy var progressLayer: YQProgressLayer = {
        let layer = YQProgressLayer.create()
        self.scrollView.layer.addSublayer(layer)
        return layer
    }()

    override init(frame: CGRect) {
        scrollView = UIScrollView()
        imageContainerView = UIView()
        imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.runLoopMode = RunLoop.Mode.default
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

        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapAction(gesture:)))
        oneTap.numberOfTapsRequired = 1
        addGestureRecognizer(oneTap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        oneTap.require(toFail: doubleTap)
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
            imageContainerView.height = scrollView.height
            imageContainerView.width = floor(image.size.width / image.size.height * scrollView.height)
        } else {
            var height = image.size.height / image.size.width * scrollView.width
            if height < 1 || height.isNaN {
                height = scrollView.height
            }
            imageContainerView.height = floor(height)
        }
        imageContainerView.center = CGPoint(x: scrollView.width / 2, y: scrollView.height / 2)
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
    @objc func doubleTapAction(gesture: UITapGestureRecognizer) {
        if (scrollView.zoomScale > 1) {
            scrollView.setZoomScale(1, animated: true)
        } else {
            let location = gesture.location(in: imageView)
            let xSize = scrollView.width / scrollView.maximumZoomScale
            let ySize = scrollView.height / scrollView.maximumZoomScale
            scrollView.zoom(to: CGRect(x: location.x - xSize / 2, y: location.y - ySize / 2, width: xSize, height: ySize), animated: true)
        }
    }

    @objc func oneTapAction(gesture: UITapGestureRecognizer) {
        delegate?.clickOnce(self)
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
