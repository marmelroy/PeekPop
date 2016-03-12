//
//  PeekPop3DTouchDelegate.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 11/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation


class PeekPop3DTouchDelegate : NSObject, UIViewControllerPreviewingDelegate {
    
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
            return delegate.previewingContext(context, viewControllerForLocation: location)
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