//
//  CollectionViewController.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/14.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit
import YQPhotoBrowser

private let reuseIdentifier = "CollectionViewCell"

class CollectionViewController: UICollectionViewController {
    lazy var dataArray: [String]  = {
        return ["https://t7.baidu.com/it/u=848096684,3883475370&fm=193&f=GIF",
                "https://t7.baidu.com/it/u=4162611394,4275913936&fm=193&f=GIF",
                "https://t7.baidu.com/it/u=4254919379,3719403362&fm=193&f=GIF",
                "https://t7.baidu.com/it/u=1653814446,2847580380&fm=193&f=GIF",
                "https://t7.baidu.com/it/u=1517419723,1472324058&fm=193&f=GIF",
                "https://t7.baidu.com/it/u=3919052749,3204254734&fm=193&f=GIF",
                "https://t7.baidu.com/it/u=3458259832,1200281189&fm=193&f=GIF",
                "https://t7.baidu.com/it/u=3019859441,4021962683&fm=193&f=GIF",
        ]
    }()
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.width / 3
        collectionLayout.itemSize = CGSize(width: width, height: width)
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.minimumLineSpacing = 0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 40
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 9
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.url = self.dataArray[indexPath.item == 8 ? 0 : indexPath.item];
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageView = (collectionView.cellForItem(at: indexPath) as! CollectionViewCell).imgView
    
        YQPhotoBrowser.presented(by: self, with: imageView, numberOfSections: {40}, numberOfItems: { section in
            return self.dataArray.count + 1
        }, defaultIndex: indexPath, itemResource: { (indexPath) -> YQPhotoResource in
            if indexPath.item == 8 {
                let videoUrl = Bundle.main.path(forResource: "a", ofType: "MOV")!
                if FileManager.default.fileExists(atPath: videoUrl) {
                    print("\(videoUrl) 文件存在")
                } else {
                    print("\(videoUrl) 文件不存在")
                }
                let imgUrl = Bundle.main.path(forResource: "a", ofType: "jpeg")!
                
                if FileManager.default.fileExists(atPath: videoUrl) {
                    print("\(imgUrl) 文件存在")
                } else {
                    print("\(imgUrl) 文件不存在")
                }
                
                return YQPhotoResource(url:URL(fileURLWithPath: imgUrl), thumbnail: URL(fileURLWithPath: imgUrl), type: .livePhoto, additionalUrl: URL(fileURLWithPath: videoUrl))
            } else if indexPath.item == 7 {
                let videoUrl = Bundle.main.path(forResource: "a", ofType: "MOV")!
                return YQPhotoResource(url: URL(fileURLWithPath: videoUrl), thumbnail: URL(string: self.dataArray[indexPath.item]), type: .video)
            }
            return YQPhotoResource(url: URL(string: self.dataArray[indexPath.item])!, thumbnail: nil)
            
        }, selected: { (indexPath) in
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }, dismiss: { (indexPath, state) -> UIImageView? in
                if state == .begin {
                    return (collectionView.cellForItem(at: indexPath) as? CollectionViewCell)?.imgView
                }
                return nil
        }, showNumber: true)
    }
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
