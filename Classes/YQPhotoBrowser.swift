//
//  YQPhotoBrowser.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit

public typealias YQPhotoGetter = (Int) -> URL

public class YQPhotoBrowser: UIViewController {

    var numberOfItems = 0
    var urlForItemAtIndex: YQPhotoGetter?
    var selectedIndex = 0
    var backgroundImage: UIImage?
    private var collectionView: UICollectionView!
    private var tempImgView: YQPhotoImageView?
    private weak var paningCell: YQPhotoCell?
    private var beginPoint = CGPoint.zero
    private var isPresented = false
    private var isFirstAppear = true
    private var backgroundImgView: UIImageView?
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    override open func viewDidLoad() {
        super.viewDidLoad()
        if let bg = backgroundImage {
            backgroundImgView = UIImageView(image: bg)
            backgroundImgView?.frame = UIScreen.main.bounds
            view.addSubview(backgroundImgView!)
        }
        blurView.frame = UIScreen.main.bounds
        view.addSubview(blurView)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(gesture:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
        prepareCollectionView()

        if let temp = tempImgView {
            view.addSubview(temp)
        }

        self.blurView.alpha = 0

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppear {
            isFirstAppear = false
            let rect = adjustTempImgViewSize()
            UIView.animate(withDuration: 0.25, delay: 0, options: [.layoutSubviews], animations: {
                self.blurView.alpha = 1
                self.tempImgView?.frame = rect
            }) { (finished) in
                self.collectionView.isHidden = false
                self.isPresented = true
                self.tempImgView?.removeFromSuperview()
            }

        }
    }
    func adjustTempImgViewSize() -> CGRect{
        var rect = CGRect.zero
        if let imgView = self.tempImgView {
            rect.size.width = UIScreen.main.width
            guard let image = imgView.image else {
                return rect
            }
            if image.size.height / image.size.width > UIScreen.main.height / UIScreen.main.width {
                rect.size.height = UIScreen.main.height
                rect.size.width = floor(image.size.width / image.size.height * UIScreen.main.height)
            } else {
                var height = image.size.height / image.size.width * UIScreen.main.width
                if height < 1 || height.isNaN {
                    height = UIScreen.main.height
                }
                rect.size.height = floor(height)
            }
            rect.origin = CGPoint(x: (UIScreen.main.width - rect.size.width) / 2, y: UIScreen.main.height / 2 - rect.size.height / 2)
            if (imgView.height > UIScreen.main.height && imgView.height - UIScreen.main.height <= 1) {
                rect.size.height = UIScreen.main.height;
            }
        }

        return rect
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
        collectionView.isHidden = true
        view.addSubview(collectionView)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .left, animated: false)
        }
    }

    public class func presented(by presentedController: UIViewController, with imageView: UIImageView?, numberOfItems: Int, selectedIndex: Int, getter: @escaping YQPhotoGetter) {
        let browser = YQPhotoBrowser()
        if let imgView = imageView {
            let rect = imgView.superview!.convert(imgView.frame, to: nil)
            let tempImgView = YQPhotoImageView(image: imgView.image)
            tempImgView.frame = rect
            tempImgView.clipsToBounds = true
            browser.tempImgView = tempImgView
        }
        browser.numberOfItems = numberOfItems
        browser.urlForItemAtIndex = getter
        browser.selectedIndex = selectedIndex

        if let window = UIApplication.shared.keyWindow {
            UIGraphicsBeginImageContext(window.bounds.size)
            window.layer.render(in: UIGraphicsGetCurrentContext()!)
            browser.backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

        presentedController.present(browser, animated: false)

    }


    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func panAction(gesture: UIPanGestureRecognizer) {

        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)), let cell = collectionView.cellForItem(at: indexPath) as? YQPhotoCell else {
                return
            }
            paningCell = cell
            if isPresented {
                beginPoint = gesture.location(in: cell)
            } else {
                beginPoint = CGPoint.zero
            }
        case .changed:
            guard let cell = paningCell, !beginPoint.equalTo(CGPoint.zero) else {
                return
            }
            let p = gesture.location(in: cell)
            let deltaY = p.y - beginPoint.y
            cell.scrollView.top = deltaY
            var alpha = (160 - fabs(deltaY) + 50) / 160
            alpha = yq_clamp(alpha, 0, 1)
            UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear], animations: {
                self.blurView.alpha = alpha
            }, completion: nil)

        case .ended:
            guard let cell = paningCell, !beginPoint.equalTo(CGPoint.zero) else {
                return
            }
            let v = gesture.velocity(in: cell)
            let p = gesture.location(in: cell)
            let deltaY = p.y - beginPoint.y

            if fabs(v.y) > 1000 || fabs(deltaY) > 160 {
                isPresented = false
                var moveToTop = deltaY < 0
                var vy = fabs(v.y)
                if vy > 100 {
                    moveToTop = v.y < 0
                }
                if vy < 1 {
                    vy =  1
                }

                var duration = (moveToTop ? cell.scrollView.bottom : cell.height - cell.scrollView.top) / vy
                duration *= 0.8
                duration = yq_clamp(duration, 0.05, 0.25)
                UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveLinear, .beginFromCurrentState], animations: {
                    if moveToTop {
                        cell.scrollView.bottom = 0
                    } else {
                        cell.scrollView.top = cell.height
                    }
                    self.blurView.alpha = 0
                }, completion: { (finished) in
                    self.dismiss(animated: false, completion: nil)
                })
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: v.y / 1000, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
                    cell.scrollView.top = 0
                    self.blurView.alpha = 1
                }, completion: nil)
            }
        case .cancelled:
            guard let cell = paningCell else {
                return
            }
            cell.scrollView.top = 0
            self.blurView.alpha = 1
        default:
            break
        }


    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

// MARK: UICollectionView
extension YQPhotoBrowser: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(YQPhotoCell.self)", for: indexPath) as! YQPhotoCell
        if let closure = urlForItemAtIndex {
            cell.url = closure(indexPath.item)
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }

}


