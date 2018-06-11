//
//  YQPhotoAnimater.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/11.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation
import UIKit

class YQPhotoAnimater: UIPercentDrivenInteractiveTransition {
    var tempImgView: UIImageView?
}

extension YQPhotoAnimater: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YQPhotoPresentAnimater(tempImgView)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YQPhotoDismissAnimater(tempImgView)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
}

class YQPhotoPresentAnimater: NSObject, UIViewControllerAnimatedTransitioning {

    var tempImgView: UIImageView?

    init(_ imgView: UIImageView?) {
        tempImgView = imgView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let _ = tempImgView else {return 0}
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let imgView = tempImgView, let toView = transitionContext.view(forKey: .to) else {
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        toView.alpha = 0
        containerView.addSubview(imgView)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            imgView.frame = self.finalFrame(imgView)
            toView.alpha = 1
        }) { (finished) in
            transitionContext.completeTransition(finished)
            imgView.removeFromSuperview()
        }
    }

    func finalFrame(_ imgView: UIImageView) -> CGRect{
        var rect = CGRect.zero
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
        return rect
    }
}

class YQPhotoDismissAnimater: NSObject, UIViewControllerAnimatedTransitioning {
    var tempImgView: UIImageView?

    init(_ imgView: UIImageView?) {
        tempImgView = imgView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let imgView = tempImgView, let  fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {return}
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        containerView.addSubview(imgView)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveLinear, .beginFromCurrentState], animations: {
            fromView.alpha = 0
            imgView.frame = CGRect.zero
        }) { (finished) in
            transitionContext.completeTransition(finished)
            if !finished {
                fromView.alpha = 1
            }
            fromView.removeFromSuperview()
            imgView.removeFromSuperview()

        }
    }


}
