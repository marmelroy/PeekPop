//
//  PeekPop.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 06/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

public class PeekPop {
    
    var viewController: UIViewController
    
    var thresholds = [0.33, 0.66, 1.0]
        
    private var previewingContexts = [PreviewingContext]()
    
    var peekPopView: PeekPopView?
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // Registers a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func registerForPreviewingWithDelegate(delegate: PeekPopPreviewingDelegate, sourceView: UIView) -> PreviewingContext {
        let previewing = PreviewingContext(delegate: delegate, sourceView: sourceView, sourceRect: sourceView.frame)
        previewingContexts.append(previewing)
        let gestureRecognizer = PeekPopGestureRecognizer(target: self, action: "didPop")
        gestureRecognizer.traitCollection = viewController.traitCollection
        gestureRecognizer.sourceView = sourceView
        viewController.view.addGestureRecognizer(gestureRecognizer)
        return previewing
    }
    
    // Unregisters a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func unregisterForPreviewingWithContext(previewing: PreviewingContext) {
        if let contextIndex = previewingContexts.indexOf(previewing) {
            previewingContexts.removeAtIndex(contextIndex)
        }
    }
    
    func peekPopAnimate(progress: Double) {
        // If there aren't any screenshots, take them
        if peekPopView == nil {
            let view = PeekPopView()
            UIApplication.sharedApplication().windows.first?.subviews.first?.addSubview(view)
            peekPopView = view
            peekPopView?.viewControllerScreenshot = screenshotView(viewController.view)
        }
        peekPopView?.frame = viewController.view.bounds
        peekPopView?.peekPopAnimate(progress)
        print("force \(progress)")
    }
    
    func peekPopRelease() {
        peekPopView?.removeFromSuperview()
        peekPopView = nil
        print("release")
    }
    
    func screenshotView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.layer.frame.size, false, UIScreen.mainScreen().scale);
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.renderInContext(context)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return image
            }
        }
        UIGraphicsEndImageContext()
        return nil
    }

    
    
}

public struct PreviewingContext {
    public let delegate: PeekPopPreviewingDelegate
    public let sourceView: UIView
    public let sourceRect: CGRect
}

extension PreviewingContext: Equatable {}
public func ==(lhs: PreviewingContext, rhs: PreviewingContext) -> Bool {
    return lhs.sourceView == rhs.sourceView
}


public protocol PeekPopPreviewingDelegate {
    // If you return nil, a preview presentation will not be performed
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController?
    func previewingContext(previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController)
}
