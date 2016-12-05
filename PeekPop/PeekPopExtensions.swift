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
