//
//  ViewController.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/2.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    lazy var dataArray: [String]  = {
        return ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496405460191&di=480afcff086c1a4a1e4afce0341830dd&imgtype=0&src=http%3A%2F%2Fmvimg1.meitudata.com%2F56cea5d03f5493829.jpg",
                "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496405460181&di=276302b3cf58c4f4331f8ba4be550e2c&imgtype=0&src=http%3A%2F%2Fimg02.tooopen.com%2Fimages%2F20160427%2Ftooopen_sy_160701449393.jpg",
                "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496406031513&di=3f05bfecba0688fe0b1002ab8108b756&imgtype=0&src=http%3A%2F%2Fimg17.3lian.com%2Fd%2Ffile%2F201702%2F16%2Fc739f33257cb00cc209b533fdfebe85d.jpg",
                ]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "\(TableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(TableViewCell.self)")
        tableView.rowHeight = 200.0
        tableView.reloadData()
    }

    @IBAction func show(_ sender: UIButton) {
//        YQPhotoBrowser.presented(by: self, with: nil, numberOfItems: dataArray.count) { (index) -> URL in
//            return URL(string: self.dataArray[index])!
//        }
    }
    @IBOutlet weak var showPhotos: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(TableViewCell.self)", for: indexPath) as! TableViewCell
        cell.url = dataArray[indexPath.item]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageView = (tableView.cellForRow(at: indexPath) as! TableViewCell).imgView
//        YQPhotoBrowser.presented(by: self, with: imageView, numberOfItems: dataArray.count, defaultIndex: indexPath.row, itemUrl:{ (index) -> URL in
//            return
//        })
//        YQPhotoBrowser.presented(by: self, with: imageView, numberOfItems: { section in
//            return self.dataArray.count
//        }, defaultIndex: IndexPath(item: indexPath.row, section: 0), itemUrl: { (indexPath) -> URL in
//            return URL(string: self.dataArray[indexPath.item])!
//        }, selected: { (indexPath) in
//            print(indexPath)
//        }) { (indexPath, state) -> UIImageView? in
//            if state == .begin {
//                return (self.tableView.cellForRow(at: indexPath) as? TableViewCell)?.imgView
//            }
//            return nil
//        }
    }
    
}

