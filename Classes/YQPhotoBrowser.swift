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
private let kTriggerOffset: CGFloat = 60.0
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
    private var isHiddenStatusBar = false


    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(gesture:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
        prepareCollectionView()
        prepareViews()
        animater.delegate = self
        animater.tempImgView = tempImgView
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
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: self.selectedIndex, at: .left, animated: false)
        }
    }

    public class func presented(by presentedController: UIViewController, with imageView: UIImageView?, numberOfSections:(() -> Int)? = nil, numberOfItems: ((Int) -> Int)? = nil, defaultIndex: IndexPath, itemUrl: @escaping((IndexPath) -> URL), selected:((IndexPath) -> Void)? = nil, dismiss:((IndexPath,YQPhotoDismissState) -> UIImageView?)? = nil) {
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

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debugPrint("willDisappear")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setNeedsStatusBarAppearanceUpdate()

        debugPrint("willAppear")
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugPrint("didAppear")
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
        debugPrint("style")
        return .lightContent
    }
    public override var prefersStatusBarHidden: Bool {
        debugPrint("isHiddenStatusBar \(isHiddenStatusBar)")
        return isHiddenStatusBar
    }
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }

}

// MARK: UICollectionView
extension YQPhotoBrowser: UICollectionViewDelegate, UICollectionViewDataSource, YQPhotoCellDelegate {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(YQPhotoCell.self)", for: indexPath) as! YQPhotoCell
        cell.delegate = self
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

    func clickOnce(_ cell: YQPhotoCell) {
        clearScreen()
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

    func animaterWillStartPresentTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = true
    }

    func animaterDidEndPresentTransition(_ animater: YQPhotoAnimater?) {
        collectionView.isHidden = false
    }

    func animaterWillStartInteractiveTransition(_ animater: YQPhotoAnimater?) -> (UIImageView, UIImageView?){
        collectionView.isHidden = true
        let fromImgView = (collectionView.cellForItem(at: selectedIndex) as! YQPhotoCell).imageView
        let toImgView = dismission?(selectedIndex,.begin)
        toImgView?.isHidden = true
        return (fromImgView, toImgView)
    }

    func animaterDidEndInteractiveTransition(_ animater: YQPhotoAnimater?, _ toImageView: UIImageView?) {
        collectionView.isHidden = false
        let _ = dismission?(selectedIndex,.finish)
        toImageView?.isHidden = false
        setNeedsStatusBarAppearanceUpdate()
    }

}

