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
        layer.lineCap = CAShapeLayerLineCap.round
        layer.strokeStart = 0
        layer.strokeEnd = 0
        layer.isHidden = true
        return layer
    }
}

class YQPhotoCell: UICollectionViewCell, YQPhotoCellCompatible {

    private enum OriginalImageLoadState {
        case idle
        case loading
        case loaded
        case failed
    }

    var beginPoint = CGPoint.zero
    weak var delegate: YQPhotoCellDelegate?
    var autoLoadOriginalImage: Bool = true {
        didSet {
            updateOriginalImageButtonVisibility()
        }
    }
    var resource: YQPhotoResource? {
        didSet {
            scrollView.zoomScale = 1
            scrollView.maximumZoomScale = 1
            resetForNewResource()
            guard let resource = self.resource, let url = resource.url else {
                return
            }

            let identifier = url.absoluteString
            resourceIdentifier = identifier

            if shouldAutoLoadOriginalImage(for: resource) {
                loadThumbnail(for: resource, identifier: identifier) { [weak self] in
                    guard let self = self, self.resourceIdentifier == identifier else {
                        return
                    }
                    self.loadOriginalImage(for: resource, identifier: identifier, showProgressLayer: !url.isFileURL, isManualTrigger: false)
                }
            } else {
                loadThumbnail(for: resource, identifier: identifier)
                originalImageLoadState = .idle
                updateOriginalImageButtonTitle()
                if !url.isFileURL {
                    tryDisplayCachedOriginalImageIfAvailable(for: resource, identifier: identifier)
                }
            }
        }
    }
    let scrollView: UIScrollView
    let imageContainerView: UIView
    let imageView: AnimatedImageView
    private let originalImageButton: UIButton
    lazy var progressLayer: YQProgressLayer = {
        let layer = YQProgressLayer.create()
        self.scrollView.layer.addSublayer(layer)
        return layer
    }()
    private var resourceIdentifier: String?
    private var manualLoadingProgressText: String = "加载中"
    private var overlayControlsHidden: Bool = false {
        didSet {
            updateOriginalImageButtonVisibility()
        }
    }
    private var originalImageLoadState: OriginalImageLoadState = .loaded {
        didSet {
            updateOriginalImageButtonVisibility()
        }
    }

    override init(frame: CGRect) {
        scrollView = UIScrollView()
        imageContainerView = UIView()
        imageView = AnimatedImageView()
        originalImageButton = UIButton(type: .custom)
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
        prepareOriginalImageButton()

        let oneTap = UITapGestureRecognizer(target: self, action: #selector(oneTapAction(gesture:)))
        oneTap.numberOfTapsRequired = 1
        addGestureRecognizer(oneTap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        oneTap.require(toFail: doubleTap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.setZoomScale(1, animated: false)
        resetForNewResource()
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
        progressLayer.position = CGPoint(x: self.width / 2, y: self.height / 2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOverlayControlsHidden(_ isHidden: Bool) {
        overlayControlsHidden = isHidden
    }

    private func prepareOriginalImageButton() {
        originalImageButton.yq.then { button in
            button.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            button.layer.cornerRadius = 16
            button.layer.masksToBounds = true
            button.isHidden = true
            button.addTarget(self, action: #selector(loadOriginalImageByTap), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(button)
        }
        NSLayoutConstraint.activate([
            originalImageButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            originalImageButton.heightAnchor.constraint(equalToConstant: 32),
            originalImageButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 143),
            originalImageButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20),
            originalImageButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20),
            originalImageButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -96)
        ])
    }

    private func resetForNewResource() {
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        progressLayer.isHidden = true
        progressLayer.progress = 0
        manualLoadingProgressText = "加载中"
        originalImageLoadState = .loaded
        resourceIdentifier = nil
    }

    private func loadThumbnail(for resource: YQPhotoResource, identifier: String, completion: (() -> Void)? = nil) {
        if let thumbnail = resource.thumbnail as? UIImage {
            imageView.image = thumbnail
            resizeSubviews()
            completion?()
            return
        }
        if let thumbnail = resource.thumbnail as? URL {
            imageView.kf.setImage(with: thumbnail, placeholder: nil, options: nil, progressBlock: nil) { [weak self] result in
                guard let self = self, self.resourceIdentifier == identifier else { return }
                switch result {
                case .success:
                    self.resizeSubviews()
                case .failure:
                    break
                }
                completion?()
            }
            return
        }
        completion?()
    }

    private func shouldAutoLoadOriginalImage(for resource: YQPhotoResource) -> Bool {
        if !isImageType(resource.type) {
            return true
        }
        return autoLoadOriginalImage
    }

    private func supportsManualOriginalImageButton(for resource: YQPhotoResource) -> Bool {
        return !autoLoadOriginalImage && isImageType(resource.type)
    }

    private func isImageType(_ type: YQPhotoItemType) -> Bool {
        switch type {
        case .jpeg, .png, .gif:
            return true
        default:
            return false
        }
    }

    private func tryDisplayCachedOriginalImageIfAvailable(for resource: YQPhotoResource, identifier: String) {
        guard let url = resource.url else { return }
        guard KingfisherManager.shared.cache.imageCachedType(forKey: url.absoluteString) != .none else {
            return
        }
        originalImageLoadState = .loaded
        let options: KingfisherOptionsInfo = [.backgroundDecode, .onlyFromCache]
        imageView.kf.setImage(with: url, placeholder: imageView.image, options: options, progressBlock: nil) { [weak self] result in
            guard let self = self, self.resourceIdentifier == identifier else { return }
            switch result {
            case .success:
                self.resizeSubviews()
            case .failure:
                self.originalImageLoadState = .idle
            }
        }
    }

    private func loadOriginalImage(for resource: YQPhotoResource, identifier: String, showProgressLayer: Bool, isManualTrigger: Bool) {
        guard let url = resource.url else { return }
        var options: KingfisherOptionsInfo = [.backgroundDecode]
        if url.isFileURL {
            options.append(.forceRefresh)
        }
        imageView.kf.cancelDownloadTask()
        if showProgressLayer {
            progressLayer.position = CGPoint(x: self.width / 2, y: self.height / 2)
            progressLayer.progress = 0
            progressLayer.isHidden = false
        } else {
            progressLayer.isHidden = true
        }

        if isManualTrigger {
            manualLoadingProgressText = "加载中"
            originalImageLoadState = .loading
            updateOriginalImageButtonTitle()
        }

        imageView.kf.setImage(with: url, placeholder: imageView.image, options: options) { [weak self] receivedSize, totalSize in
            guard let self = self, self.resourceIdentifier == identifier else { return }
            if isManualTrigger {
                if totalSize > 0 {
                    let percent = yq_clamp(Int((Double(receivedSize) / Double(totalSize)) * 100.0), 0, 100)
                    self.manualLoadingProgressText = "加载中 \(percent)%"
                } else {
                    self.manualLoadingProgressText = "加载中"
                }
                self.updateOriginalImageButtonTitle()
            } else if totalSize > 0 {
                self.progressLayer.progress = Double(receivedSize) / Double(totalSize)
            }
        } completionHandler: { [weak self] result in
            guard let self = self, self.resourceIdentifier == identifier else { return }
            self.progressLayer.isHidden = true
            switch result {
            case .success:
                self.resizeSubviews()
                if isManualTrigger {
                    self.originalImageLoadState = .loaded
                }
            case .failure:
                if isManualTrigger {
                    self.originalImageLoadState = .failed
                }
            }
        }
    }

    private func updateOriginalImageButtonVisibility() {
        guard let resource = resource, supportsManualOriginalImageButton(for: resource) else {
            originalImageButton.isHidden = true
            return
        }
        guard !overlayControlsHidden else {
            originalImageButton.isHidden = true
            return
        }
        switch originalImageLoadState {
        case .loaded:
            originalImageButton.isHidden = true
        case .idle, .loading, .failed:
            originalImageButton.isHidden = false
            updateOriginalImageButtonTitle()
        }
    }

    private func updateOriginalImageButtonTitle() {
        guard let resource = resource else {
            originalImageButton.setTitle(nil, for: .normal)
            return
        }
        let title: String
        switch originalImageLoadState {
        case .loading:
            title = manualLoadingProgressText
        case .idle, .failed, .loaded:
            title = originalImageButtonTitle(for: resource)
        }
        originalImageButton.setTitle(title, for: .normal)
    }

    private func originalImageButtonTitle(for resource: YQPhotoResource) -> String {
        guard let byteSize = resource.originalImageByteSize, byteSize > 0 else {
            return "查看原图"
        }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.includesCount = true
        formatter.isAdaptive = true
        let sizeText = formatter.string(fromByteCount: byteSize).replacingOccurrences(of: " ", with: "")
        return "查看原图\(sizeText)"
    }
}

//MARK: Action
extension YQPhotoCell {
    @objc func loadOriginalImageByTap() {
        guard let resource = resource, let identifier = resourceIdentifier else {
            return
        }
        guard supportsManualOriginalImageButton(for: resource) else {
            return
        }
        loadOriginalImage(for: resource, identifier: identifier, showProgressLayer: false, isManualTrigger: true)
    }

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
