//
//  CollectionViewController.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/14.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CollectionViewCell"

class CollectionViewController: UICollectionViewController {
    lazy var dataArray: [String]  = {
        return ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496405460191&di=480afcff086c1a4a1e4afce0341830dd&imgtype=0&src=http%3A%2F%2Fmvimg1.meitudata.com%2F56cea5d03f5493829.jpg",
                "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528993047751&di=997c4dbe0724041005216940ba87de8f&imgtype=0&src=http%3A%2F%2Fwww.sinaimg.cn%2Fdy%2Fslidenews%2F3_img%2F2017_12%2F85178_417292_127040.jpg",
                "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496405460181&di=276302b3cf58c4f4331f8ba4be550e2c&imgtype=0&src=http%3A%2F%2Fimg02.tooopen.com%2Fimages%2F20160427%2Ftooopen_sy_160701449393.jpg",
                "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528996792630&di=13eea2e39d7523a52c1fdc46297a36db&imgtype=0&src=http%3A%2F%2Fs13.sinaimg.cn%2Fmw690%2F006d2iVGgy6VEqNAKM48c%26690",
                "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496406031513&di=3f05bfecba0688fe0b1002ab8108b756&imgtype=0&src=http%3A%2F%2Fimg17.3lian.com%2Fd%2Ffile%2F201702%2F16%2Fc739f33257cb00cc209b533fdfebe85d.jpg",
                "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528996905414&di=d972614c1216afb1fcc4e7ca140ccff3&imgtype=0&src=http%3A%2F%2Fs17.mogucdn.com%2Fp1%2F160420%2F130571905_ie4geytggbsgcojqhazdambqgiyde_640x960.jpg_468x468.jpg",
                ]
    }()
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()

        let width = UIScreen.main.width / 3
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
        return 6
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.url = self.dataArray[indexPath.item]
        // Configure the cell
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageView = (collectionView.cellForItem(at: indexPath) as! CollectionViewCell).imgView
        YQPhotoBrowser.presented(by: self, with: imageView, numberOfSections: {40}, numberOfItems: { section in
            return self.dataArray.count
        }, defaultIndex: indexPath, itemUrl: { (indexPath) -> URL in
            return URL(string: self.dataArray[indexPath.item])!
        }, selected: { (indexPath) in
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }) { (indexPath, state) -> UIImageView? in
            if state == .begin {
                return (collectionView.cellForItem(at: indexPath) as? CollectionViewCell)?.imgView
            }
            return nil
        }
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
