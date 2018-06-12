//
//  YQPhotoAnimater.swift
//  YQPhotoBrowser
//
//  Created by 王叶庆 on 2018/6/11.
//  Copyright © 2018年 Wang. All rights reserved.
//

import Foundation
import UIKit

//class YQPhotoAnimater: UIPercentDrivenInteractiveTransition {
//    var tempImgView: UIImageView?
//    var toImgView: UIImageView?
//    override func finish() {
////        guard let imgView = toImgView else {
////            DispatchQueue.main.async {
////                UIView.animate(withDuration: 0.25, animations: {
////                    self.tempImgView?.frame = CGRect(x: 0, y: UIScreen.main.height - 50, width: 50, height: 50)
////                }, completion: {finished in
////                    super.finish()
////                    self.tempImgView?.removeFromSuperview()
////                })
////            }
////            return
////        }
//        super.finish()
//    }
//
//}

protocol YQPhotoDismissAimaterDelegate {
    func animaterWillStartInteractiveTransition(_ animater: YQPhotoAnimater)
    func animaterDidEndInteractiveTransition(_ animater: YQPhotoAnimater)
}


class YQPhotoAnimater: NSObject, UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let imgView = tempImgView, let toView = transitionContext.view(forKey: .to) else {return}
        self.transitionContext = transitionContext
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.sendSubview(toBack: toView)
        containerView.addSubview(imgView)
        beginFrame = imgView.frame
        delegate?.animaterWillStartInteractiveTransition(self)
    }

    var wantsInteractiveStart: Bool {
        return false
    }
    var tempImgView: UIImageView?
    var toImgView: UIImageView?
    private var transitionContext: UIViewControllerContextTransitioning?
    private var beginFrame: CGRect!
    var delegate: YQPhotoDismissAimaterDelegate?
    
    public init(_ delegate: YQPhotoDismissAimaterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func finish() {
        guard let tempImgView = tempImgView, let fromView = self.transitionContext?.view(forKey: .from) else {
            fatalError()
        }
        var rect: CGRect
        if let imgView = toImgView {
            rect = imgView.superview!.convert(imgView.frame, to: nil)
        } else {
            rect = CGRect(x: 0, y: 0, width: 50, height: 50)
            rect.center = CGPoint(x: UIScreen.main.width / 2, y: UIScreen.main.height + rect.height / 2)
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear, .beginFromCurrentState], animations: {
            tempImgView.frame = rect
            fromView.alpha = 0
        }, completion: {finished in
            tempImgView.removeFromSuperview()
            self.transitionContext?.finishInteractiveTransition()
            self.transitionContext?.completeTransition(true)
        })
    }

    func cancel() {
        guard let imgView = tempImgView, let fromView = self.transitionContext?.view(forKey: .from) else {
            fatalError()
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveLinear, .beginFromCurrentState], animations: {
            imgView.frame = self.beginFrame
            fromView.alpha = 1
        }, completion: {finished in
            imgView.removeFromSuperview()
            self.transitionContext?.cancelInteractiveTransition()
            self.transitionContext?.completeTransition(false)
            self.delegate?.animaterDidEndInteractiveTransition(self)
        })
    }

    func move(_ offset: CGPoint) {
        guard let imgView = tempImgView, let fromView = self.transitionContext?.view(forKey: .from) else {return}
        let delta = yq_clamp(1 - offset.y / UIScreen.main.height, 0, 1)
        fromView.alpha = delta
        let beginCenter = beginFrame.center
        let width = beginFrame.width * delta
        let height = beginFrame.height * delta
        var frame = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
        frame.center = CGPoint(x: beginCenter.x + offset.x, y: beginCenter.y + offset.y)
        imgView.frame = frame
    }
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
            rect.size.height = UIScreen.main.height
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
