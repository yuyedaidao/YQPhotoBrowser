//
//  PlayerViewController.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/19.
//  Copyright © 2018年 Wang. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = Bundle.main.path(forResource: "IMG_0097", ofType: "MOV")
        let player = AVPlayer(url: URL(fileURLWithPath: url!))
        let layer = AVPlayerLayer(player: player)
        view.layer.addSublayer(layer)
        layer.frame = view.bounds
        player.play()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            let layer2 = AVPlayerLayer(player: player)
            layer2.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            self.view.layer.addSublayer(layer2)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
