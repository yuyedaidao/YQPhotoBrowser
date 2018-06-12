//
//  YQPhotoBrowser.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit

public typealias YQPhotoGetter = (Int) -> URL
private let kTriggerOffset: CGFloat = 120.0
public class YQPhotoBrowser: UIViewController {

    var numberOfItems = 0
    var urlForItemAtIndex: YQPhotoGetter?
    var selectedIndex = 0
    private var collectionView: UICollectionView!
    private var tempImgView: UIImageView?
    private var beginPoint = CGPoint.zero
    private let animater = YQPhotoAnimater()

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(gesture:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
        prepareCollectionView()

        animater.tempImgView = tempImgView
        transitioningDelegate = animater
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            self.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .left, animated: false)
        }
    }

    public class func presented(by presentedController: UIViewController, with imageView: UIImageView?, numberOfItems: Int, selectedIndex: Int, getter: @escaping YQPhotoGetter) {
        let browser = YQPhotoBrowser()
        if let imgView = imageView {
            let rect = imgView.superview!.convert(imgView.frame, to: nil)
            let tempImgView = UIImageView(image: imageView?.image)
            tempImgView.frame = rect
            tempImgView.clipsToBounds = true
            browser.tempImgView = tempImgView
        }
        browser.numberOfItems = numberOfItems
        browser.urlForItemAtIndex = getter
        browser.selectedIndex = selectedIndex
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
            tempImgView = UIImageView(image: cell.imageView.image)
            tempImgView!.frame = cell.imageView.superview!.convert(cell.imageView.frame, to: nil)
            animater.tempImgView = tempImgView
            collectionView.isHidden = true
            dismiss(animated: true) {

            }
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
                collectionView.isHidden = false
            }
        case .failed, .cancelled:
            animater.cancel()
            collectionView.isHidden = false
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


