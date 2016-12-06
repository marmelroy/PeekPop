//
//  PeekPopExtensions.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 11/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

extension UIView {
    
    func screenshotView(_ inHierarchy: Bool = true, rect: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.layer.frame.size, false, UIScreen.main.scale);
        defer{
            UIGraphicsEndImageContext()
        }
        if inHierarchy == true {
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        }
        else {
            if let context = UIGraphicsGetCurrentContext() {
                self.layer.render(in: context)
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let rectTransform = CGAffineTransform(scaleX: (image?.scale)!, y: (image?.scale)!)
        if let rect = rect, let croppedImageRef = image?.cgImage?.cropping(to: rect.applying(rectTransform)) {
            return UIImage(cgImage: croppedImageRef)
        }
        else {
            return image
        }
    }

}

extension PeekPop: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PreviewingContext: Equatable {}
public func ==(lhs: PreviewingContext, rhs: PreviewingContext) -> Bool {
    return lhs.sourceView == rhs.sourceView
}


extension UIPreviewAction{
    public override static func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        if self !== UIPreviewAction.self {
            return
        }
    

    
    dispatch_once(&Static.token) {
    let originalSelector = Selector("previewActionItems:")
    let swizzledSelector = Selector("showActionItems:")
    
    let originalMethod = class_getInstanceMethod(self, originalSelector)
    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
    
    let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    
    if didAddMethod {
    class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
    method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    }
}
}

