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
    var targetViewController: UIViewController?

    
    private var previewingContexts = [PreviewingContext]()
    
    var peekPopView: PeekPopView?
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // Registers a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func registerForPreviewingWithDelegate(delegate: PeekPopPreviewingDelegate, sourceView: UIView) -> PreviewingContext {
        let previewing = PreviewingContext(delegate: delegate, sourceView: sourceView)
        previewingContexts.append(previewing)
        let gestureRecognizer = PeekPopGestureRecognizer(target: self, action: "didPop")
        gestureRecognizer.traitCollection = viewController.traitCollection
        gestureRecognizer.context = previewing
        viewController.view.addGestureRecognizer(gestureRecognizer)
        return previewing
    }
    
    // Unregisters a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func unregisterForPreviewingWithContext(previewing: PreviewingContext) {
        if let contextIndex = previewingContexts.indexOf(previewing) {
            previewingContexts.removeAtIndex(contextIndex)
        }
    }
    
    func peekPopAnimate(progress: Double, context: PreviewingContext?) {
        // If there aren't any screenshots, take them
        if peekPopView == nil {
            let view = PeekPopView()
            UIApplication.sharedApplication().windows.first?.subviews.first?.addSubview(view)
            peekPopView = view
            peekPopView?.viewControllerScreenshot = screenshotView(viewController.view)
            if let targetViewController = targetViewController {
                targetViewController.view.frame = viewController.view.bounds
                peekPopView?.targetViewControllerScreenshot = screenshotView(targetViewController.view, inHierarchy: false)
            }
            if let context = context {
                peekPopView?.sourceViewScreenshot = screenshotView(context.sourceView)
                peekPopView?.sourceViewRect = viewController.view.convertRect(context.sourceView.frame, toView: viewController.view)
            }
            peekPopView?.frame = viewController.view.bounds
            peekPopView?.didAppear()
        }
        else {
            peekPopView?.frame = viewController.view.bounds
        }
        peekPopView?.peekPopAnimate(progress)
        print("force \(progress)")
    }
    
    func peekPopRelease() {
        peekPopView?.removeFromSuperview()
        peekPopView = nil
        print("release")
    }
    
    func screenshotView(view: UIView, inHierarchy: Bool = true) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.layer.frame.size, false, UIScreen.mainScreen().scale);
        if inHierarchy == true {
            view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        }
        else {
            if let context = UIGraphicsGetCurrentContext() {
                view.layer.renderInContext(context)
            }
        }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return image
        }
        UIGraphicsEndImageContext()
        return nil
    }

    
    
}

public struct PreviewingContext {
    public let delegate: PeekPopPreviewingDelegate
    public let sourceView: UIView
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
