//
//  PeekPopExtensions.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 11/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

extension UIView {
    
    func screenshotView(inHierarchy: Bool = true) -> UIImage? {
        print("TAKE VIEW SCREENSHOT START \(NSDate())")
        UIGraphicsBeginImageContextWithOptions(self.layer.frame.size, false, UIScreen.mainScreen().scale);
        if inHierarchy == true {
            self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: false)
        }
        else {
            if let context = UIGraphicsGetCurrentContext() {
                self.layer.renderInContext(context)
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("TAKE VIEW SCREENSHOT END \(NSDate())")
        return image
    }

}

extension PreviewingContext: Equatable {}
public func ==(lhs: PreviewingContext, rhs: PreviewingContext) -> Bool {
    return lhs.sourceView == rhs.sourceView
}
