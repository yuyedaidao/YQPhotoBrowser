//
//  YQExtension.swift
//  YQPhotoBrowser
//
//  Created by Wang on 2017/6/6.
//  Copyright © 2017年 Wang. All rights reserved.
//

import UIKit

extension UIView {
    var top: CGFloat {
        set {
            self.frame.origin.y = newValue
        }
        
        get {
            return self.frame.origin.y
        }
    }
    
    var bottom: CGFloat {
        set {
            self.frame.origin.y = newValue - self.frame.height
        }
        
        get {
            return self.frame.maxY
        }
    }
    
    var left: CGFloat {
        set {
            self.frame.origin.x = newValue
        }
        get {
            return self.frame.origin.x
        }
    }
    
    var right: CGFloat {
        set {
            self.frame.origin.x = newValue - self.frame.width
        }
        
        get {
            return self.frame.maxX
        }
    }
    
    var width: CGFloat {
        set {
            self.frame.size.width = newValue
        }
        
        get {
            return self.frame.width
        }
    }
    
    var height: CGFloat {
        set {
            self.frame.size.height = newValue
        }
        
        get {
            return self.frame.height
        }
    }
}

extension UIScreen {
    var width: CGFloat {
        get {
            return self.bounds.width
        }
    }
    
    var height: CGFloat {
        get {
            return self.bounds.height
        }
    }
}

extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            var rect = self
            rect.origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height / 2)
            self = rect
        }
    }

}

extension String {
    var bundleImage: UIImage? {
        return UIImage(named: self, in: YQPhotoBundle.shared, compatibleWith: nil)
    }
}

extension YQPhotoBrowser {
    static var statusBarWillAnimateNotification: NSNotification.Name {
        return NSNotification.Name("yq_photoBrowser_statusBar_will_animate")
    }
    static var statusBarDidAnimateNotification: NSNotification.Name {
        return NSNotification.Name("yq_photoBrowser_statusBar_did_animate")
    }
}
