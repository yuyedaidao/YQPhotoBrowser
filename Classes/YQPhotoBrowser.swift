//
//  YQPhotoBrowser.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit

open class YQPhotoBrowser: UIViewController {

    var numberOfItems = 0
    var collectionView: UICollectionView!
    var urlForItemAtIndex: ((Int) -> URL)?
    var selectedIndex = 0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = self
        prepareCollectionView()
    }

    func prepareCollectionView() {
        let rect = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = rect.size
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.register(YQPhotoCell.self, forCellWithReuseIdentifier: "\(YQPhotoCell.self)")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


// MARK: transition

extension YQPhotoBrowser: UIViewControllerTransitioningDelegate {
    
}

