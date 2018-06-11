//
//  YQPhotoAnimater.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/11.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation
import UIKit

class YQPhotoAnimater: NSObject {
    var tempImgView: UIImageView?
}

extension YQPhotoAnimater: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
        }) { (finished) in

        }
    }

}

extension YQPhotoAnimater: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        <#code#>
    }
}

extension YQPhotoAnimater: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        fatalError()
    }
}
