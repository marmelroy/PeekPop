//
//  PeekPopExtensions.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 11/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

extension UIView {
    
    func screenshotView(inHierarchy: Bool = true, rect: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.layer.frame.size, false, UIScreen.mainScreen().scale);
        defer{
            UIGraphicsEndImageContext()
        }
        if inHierarchy == true {
            self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: false)
        }
        else {
            if let context = UIGraphicsGetCurrentContext() {
                self.layer.renderInContext(context)
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let rectTransform = CGAffineTransformMakeScale(image.scale, image.scale)
        if let rect = rect, let croppedImageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectApplyAffineTransform(rect, rectTransform)) {
            return UIImage(CGImage: croppedImageRef)
        }
        else {
            return image
        }
    }

}

extension PeekPop: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PreviewingContext: Equatable {}
public func ==(lhs: PreviewingContext, rhs: PreviewingContext) -> Bool {
    return lhs.sourceView == rhs.sourceView
}
