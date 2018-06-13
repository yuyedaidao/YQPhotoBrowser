//
//  YQPhotoBrowser.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit
import SnapKit

public enum YQPhotoDismissState{
    case begin
    case finish
}
private let kTriggerOffset: CGFloat = 140.0
public class YQPhotoBrowser: UIViewController {
    var numberOfSections:(() -> Int)?
    var numberOfItems:((Int) -> Int)?
    var itemUrl: ((IndexPath) -> URL)?
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

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(gesture:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
        prepareCollectionView()
        prepareViews()
        animater.delegate = self
        animater.tempImgView = tempImgView
        transitioningDelegate = animater
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func prepareViews() {
        topOperationView = UIView()
        topOperationView.yq.then { (view) in
            view.backgroundColor = UIColor.clear
            self.view.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(20)
                make.height.equalTo(44)
            })
            backButton = UIButton(type: .custom)
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
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: self.selectedIndex, at: .left, animated: false)
        }
    }

    public class func presented(by presentedController: UIViewController, with imageView: UIImageView?, numberOfSections:(() -> Int)? = nil, numberOfItems: ((Int) -> Int)? = nil, defaultIndex: IndexPath, itemUrl: @escaping((IndexPath) -> URL), selected: ((IndexPath) -> Void)? = nil, dismiss:((IndexPath,YQPhotoDismissState) -> UIImageView?)? = nil) {
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

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func panAction(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)), let cell = collectionView.cellForItem(at: indexPath) as? YQPhotoCell else {
                return
            }
            beginPoint = gesture.location(in: view)
            tempImgView = animatableImageView(cell.imageView.image)
            tempImgView!.frame = cell.imageView.superview!.convert(cell.imageView.frame, to: nil)
            animater.tempImgView = tempImgView
            dismiss(animated: true)
        case .changed:
            let p = gesture.location(in: view)
            animater.move(CGPoint(x: p.x - beginPoint.x, y: p.y - beginPoint.y))
        case .ended:
            let p = gesture.location(in: view)
            let deltaY = p.y - beginPoint.y
            if deltaY > kTriggerOffset {
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

    func animatableImageView(_ image: UIImage?) -> UIImageView {
        let imgView = UIImageView(image: image)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }

}

// MARK: UICollectionView
extension YQPhotoBrowser: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(YQPhotoCell.self)", for: indexPath) as! YQPhotoCell
        if let closure = itemUrl {
            cell.url = closure(indexPath)
        }
        return cell
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

    func findCurrentIndex() {
        for cell in collectionView.visibleCells {
            if cell.frame.minX == collectionView.contentOffset.x {
                selectedIndex = collectionView.indexPath(for: cell)!
                break
            }
        }
    }
}

extension YQPhotoBrowser: YQPhotoAimaterDelegate {

    func animaterWillStartPresentTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = true
    }

    func animaterDidEndPresentTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = false
    }

    func animaterWillStartInteractiveTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = true
        guard let imgView = dismission?(selectedIndex,.begin) else {return}
        imgView.isHidden = true
        animater?.toImgView = imgView
    }

    func animaterDidEndInteractiveTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = false
        let _ = dismission?(selectedIndex,.finish)
        animater?.toImgView?.isHidden = false
    }
    
    
}

