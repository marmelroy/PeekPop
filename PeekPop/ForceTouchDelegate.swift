//
//  ForceTouchDelegate.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 11/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

/// This delegate is used as a way to fallback to Apple's implementation of Peek and Pop for devices that support 3D touch. It conforms to UIViewControllerPreviewingDelegate
class ForceTouchDelegate: NSObject, UIViewControllerPreviewingDelegate {
    
    let delegate: PeekPopPreviewingDelegate
    
    init(delegate: PeekPopPreviewingDelegate) {
        self.delegate = delegate
    }
    
    func registerFor3DTouch(sourceView: UIView, viewController: UIViewController) {
        if #available(iOS 9.0, *) {
            viewController.registerForPreviewingWithDelegate(self, sourceView: sourceView)
        }
    }
    
    @objc func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            let context = PreviewingContext(delegate: delegate, sourceView: previewingContext.sourceView)
            let viewController = delegate.previewingContext(context, viewControllerForLocation: location)
            // Apply changes to previewing context's source rect
            previewingContext.sourceRect = context.sourceRect
            return viewController
        }
        return nil
    }
    
    @objc func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if #available(iOS 9.0, *) {
            let context = PreviewingContext(delegate: delegate, sourceView: previewingContext.sourceView)
            delegate.previewingContext(context, commitViewController: viewControllerToCommit)
        }
    }
    
}