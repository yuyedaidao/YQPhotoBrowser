//
//  YQPhotoBrowser.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

public enum YQPhotoDismissState{
    case begin
    case finish
}

public enum YQPhotoItemType {
    case jpeg
    case png
    case gif
    case video
}

public typealias  YQPhotoURLGetter = (IndexPath) -> (URL, YQThumbnailResource?, YQPhotoItemType)
private let kTriggerOffset: CGFloat = 60.0

public class YQPhotoBrowser: UIViewController {
    var numberOfSections:(() -> Int)?
    var numberOfItems:((Int) -> Int)?
    var itemUrl: YQPhotoURLGetter!
    var dismission: ((IndexPath, YQPhotoDismissState) -> UIImageView?)?
    var selectedIndex = IndexPath(item: 0, section: 0) {
        didSet {
            selected?(selectedIndex)
        }
    }
    private var selected: ((IndexPath) -> Void)?
    private var collectionView: UICollectionView!
    private var tempImgView: UIImageView?
    private var beginPoint = CGPoint.zero
    private let animater = YQPhotoAnimater()

    private var backButton: UIButton!
    private var shareButton: UIButton!
    private var topOperationView: UIView!
    private var bottomOperationView: UIView!
    private var isHiddenStatusBar = false

    /// 如果当前视图是视频视图，拖拽时再创建浮动视图会造成屏幕闪动现象，因此提前准备一个辅助视图
    private lazy var assistantPlayerView = {
        return YQPlayerView(player: nil)
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(gesture:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
        prepareCollectionView()
        prepareViews()
        animater.delegate = self
        animater.tempView = tempImgView
        transitioningDelegate = animater
        
    }

    func prepareViews() {
        topOperationView = UIView()
        topOperationView.yq.then { (view) in
            view.backgroundColor = UIColor.clear
            self.view.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.leading.trailing.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(20)
                } else {
                    // Fallback on earlier versions
                    make.top.equalTo(20)
                }
                make.height.equalTo(44)
            })
            backButton = UIButton(type: .custom)
            backButton.yq.then({ (button) in
                view.addSubview(button)
                button.setImage(UIImage(named: "back"), for: .normal)
                button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
                button.snp.makeConstraints({ (make) in
                    make.width.height.equalTo(30)
                    make.leading.equalTo(15)
                    make.centerY.equalTo(view)
                })
                button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            })
            shareButton = UIButton(type: .custom)
            shareButton.yq.then({ (button) in
                view.addSubview(button)
                button.setImage(UIImage(named: "share"), for: .normal)
                button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
                button.snp.makeConstraints({ (make) in
                    make.width.height.equalTo(30)
                    make.trailing.equalTo(-15)
                    make.centerY.equalTo(view)
                })
                button.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
            })
        }

        bottomOperationView = UIView()
        bottomOperationView.yq.then { (view) in
            view.backgroundColor = UIColor.clear
            self.view.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.leading.trailing.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(self.bottomLayoutGuide.snp.top).offset(-20)
                } else {
                    // Fallback on earlier versions
                    make.bottom.equalTo(-20)
                }
                make.height.equalTo(44)
            })
        }
    }

    func prepareCollectionView() {
        let rect = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = rect.size
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(YQPhotoCell.self, forCellWithReuseIdentifier: "\(YQPhotoCell.self)")
        collectionView.register(YQPhotoVideoCell.self, forCellWithReuseIdentifier: "\(YQPhotoVideoCell.self)")
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: self.selectedIndex, at: .left, animated: false)
        }
    }

    public class func presented(by presentedController: UIViewController, with imageView: UIImageView?, numberOfSections:(() -> Int)? = nil, numberOfItems: ((Int) -> Int)? = nil, defaultIndex: IndexPath, itemUrl: @escaping YQPhotoURLGetter, selected:((IndexPath) -> Void)? = nil, dismiss:((IndexPath,YQPhotoDismissState) -> UIImageView?)? = nil) {
        let browser = YQPhotoBrowser()
        if let imgView = imageView {
            let rect = imgView.superview!.convert(imgView.frame, to: nil)
            let tempImgView = UIImageView(image: imageView?.image)
            tempImgView.frame = rect
            tempImgView.clipsToBounds = true
            tempImgView.contentMode = .scaleAspectFill
            browser.tempImgView = tempImgView
        }
        browser.numberOfSections = numberOfSections
        browser.numberOfItems = numberOfItems
        browser.itemUrl = itemUrl
        browser.selectedIndex = defaultIndex
        browser.dismission = dismiss
        browser.selected = selected
        presentedController.present(browser, animated: true)
    }

}

// MARK: - Action
extension YQPhotoBrowser {
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginPoint = gesture.location(in: view)
            dismiss(animated: true)
        case .changed:
            let p = gesture.location(in: view)
            animater.move(CGPoint(x: p.x - beginPoint.x, y: p.y - beginPoint.y))
        case .ended:
            let p = gesture.location(in: view)
            let deltaY = p.y - beginPoint.y
            if deltaY > kTriggerOffset || gesture.velocity(in: view).y > 1200 {
                animater.finish()
            } else {
                animater.cancel()
            }
        case .failed, .cancelled:
            animater.cancel()
        default:
            break
        }
    }

    @objc func backAction() {
        animater.isInteractive = false
        dismiss(animated: true)
    }

    @objc func shareAction() {
        guard let cell = self.collectionView.cellForItem(at: self.selectedIndex) as? YQPhotoCell, let image = cell.imageView.image else {
            return
        }
        let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        shareController.completionWithItemsHandler = {(activityType, completed, returnItems, error) in

        }
        present(shareController, animated: true)
    }
}

// MARK: - StatusBar
extension YQPhotoBrowser {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }

}

// MARK: UICollectionView
extension YQPhotoBrowser: UICollectionViewDelegate, UICollectionViewDataSource, YQPhotoCellDelegate {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = itemUrl(indexPath)
        var cell: YQPhotoCellCompatible
        if item.2 == .video {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(YQPhotoVideoCell.self)", for: indexPath) as! YQPhotoCellCompatible
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(YQPhotoCell.self)", for: indexPath) as! YQPhotoCellCompatible
        }
        cell.delegate = self
        cell.resource = YQPhotoResource(url: item.0, thumbnail: item.1)
        return cell as! UICollectionViewCell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems?(section) ?? 0
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections?() ?? 1
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        findCurrentIndex()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        findCurrentIndex()
    }

    func clickOnce(_ cell: YQPhotoCellCompatible) {
        clearScreen()
    }

    func videoCell(_ cell: YQPhotoCellCompatible, replacePlayer player: AVPlayer?) {
        self.assistantPlayerView.player = player
    }

    func findCurrentIndex() {
        for cell in collectionView.visibleCells {
            if cell.frame.minX == collectionView.contentOffset.x {
                selectedIndex = collectionView.indexPath(for: cell)!
                break
            }
        }
    }

    func clearScreen() {
        isHiddenStatusBar = !isHiddenStatusBar
        UIView.animate(withDuration: 0.15) {
            self.setNeedsStatusBarAppearanceUpdate()
            if self.isHiddenStatusBar {
                self.topOperationView.alpha = 0
                self.bottomOperationView.alpha = 0
            } else {
                self.topOperationView.alpha = 1
                self.bottomOperationView.alpha = 1
            }
        }
    }
}

extension YQPhotoBrowser: YQPhotoAimaterDelegate {

    fileprivate func animatableImageView(_ image: UIImage?) -> UIImageView {
        let imgView = UIImageView(image: image)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }

    func animaterWillStartPresentTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = true
    }

    func animaterDidEndPresentTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = false
    }

    func animaterWillStartInteractiveTransition(_ animater: YQPhotoAnimater?) -> (UIView, UIImageView?) {
        collectionView.isHidden = true
        let toImgView = dismission?(selectedIndex,.begin)
        toImgView?.isHidden = true
        var tempView: UIView!
        let cell = collectionView.cellForItem(at: selectedIndex)
        if let photoCell = cell as? YQPhotoCell {
            let fromImgView = photoCell.imageView
            let tempImgView = animatableImageView(fromImgView.image)
            if let fromSuperView = fromImgView.superview  {
                tempImgView.frame = fromSuperView.convert(fromImgView.frame, to: nil)
            }
            tempView = tempImgView
        } else if let videoCell = cell as? YQPhotoVideoCell {
            let fromView = videoCell.playerView
            tempView = assistantPlayerView
            if videoCell.player != assistantPlayerView.player {
                assistantPlayerView.player = videoCell.player
            }
            if let fromSuperView = fromView.superview {
                tempView.frame = fromSuperView.convert(fromView.frame, to: nil)
            }
        }
        return (tempView, toImgView)
    }

    func animaterDidEndInteractiveTransition(_ animater: YQPhotoAnimater?, _ toImageView: UIImageView?, _ isCanceled: Bool) {
        collectionView.isHidden = false
        let _ = dismission?(selectedIndex,.finish)
        toImageView?.isHidden = false
        //如果是结束且是视频，要结束当前播放的视频
        if !isCanceled {
            guard let cell = collectionView.cellForItem(at: selectedIndex) as? YQPhotoVideoCell else {return}
            cell.player.pause()
        }
    }

}

