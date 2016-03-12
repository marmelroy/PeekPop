//
//  PeekPop.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 06/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

public class PeekPop: NSObject {
    
    var viewController: UIViewController
    var targetViewController: UIViewController?

    private var peekPopGestureRecognizer: PeekPopGestureRecognizer?
    var peekPopWindow: UIWindow?
    private var peekPopView: PeekPopView?
    private var previewingContexts = [PreviewingContext]()
    
    var originalDelegate: PeekPop3DTouchDelegate?
    
    /**
    Peek pop initializer
     
     - parameter viewController: hosting UIViewController
     
     - returns: PeekPop object
     */
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    /// Registers a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func registerForPreviewingWithDelegate(delegate: PeekPopPreviewingDelegate, sourceView: UIView) -> PreviewingContext {
        let previewing = PreviewingContext(delegate: delegate, sourceView: sourceView)
        previewingContexts.append(previewing)
        if #available(iOS 9.0, *) {
            if self.viewController.traitCollection.forceTouchCapability == UIForceTouchCapability.Available && TARGET_OS_SIMULATOR != 1 {
                let customDelegate = PeekPop3DTouchDelegate(delegate: delegate)
                customDelegate.registerFor3DTouch(sourceView, viewController: viewController)
                originalDelegate = customDelegate
                return previewing
            }
        }
        let gestureRecognizer = PeekPopGestureRecognizer(target: self, action: "didPop")
        gestureRecognizer.traitCollection = viewController.traitCollection
        gestureRecognizer.context = previewing
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delaysTouchesBegan = true
        viewController.view.addGestureRecognizer(gestureRecognizer)
        peekPopGestureRecognizer = gestureRecognizer
        return previewing
    }
    
    
    /// Unregisters a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func unregisterForPreviewingWithContext(previewing: PreviewingContext) {
        if let contextIndex = previewingContexts.indexOf(previewing) {
            previewingContexts.removeAtIndex(contextIndex)
        }
    }
    
    func peekPopPrepare(context: PreviewingContext?){
        let view = PeekPopView()
        peekPopView = view
        peekPopView?.viewControllerScreenshot = viewController.view.screenshotView()
        if let targetViewController = targetViewController {
            targetViewController.view.frame = viewController.view.bounds
            peekPopView?.targetViewControllerScreenshot = targetViewController.view.screenshotView(false)
        }
        if let context = context {
            peekPopView?.sourceViewScreenshot = context.sourceView.screenshotView()
            peekPopView?.sourceViewRect = viewController.view.convertRect(context.sourceView.frame, toView: viewController.view)
        }
    }
    
    func peekPopAnimate(progress: Double, context: PreviewingContext?) {
        // If there aren't any screenshots, take them
        if peekPopView?.superview == nil {
            if peekPopWindow == nil {
                let window = UIWindow(frame: UIScreen.mainScreen().bounds)
                window.windowLevel = UIWindowLevelAlert
                window.rootViewController = UIViewController()
                peekPopWindow = window
            }
            peekPopWindow?.alpha = 0.0
            peekPopWindow?.hidden = false
            peekPopWindow?.makeKeyAndVisible()
            if let peekPopView = peekPopView {
                peekPopWindow?.addSubview(peekPopView)
            }
            peekPopView?.frame = viewController.view.bounds
            peekPopView?.didAppear()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.peekPopWindow?.alpha = 1.0
            })
        }
        else {
            peekPopView?.frame = viewController.view.bounds
        }
        if progress < 0.99 {
            peekPopView?.peekPopAnimate(progress)
        }
        else {
            self.triggerTarget(context!)
        }
    }
    
    func triggerTarget(context: PreviewingContext){
        guard let targetViewController = targetViewController else {
            return
        }
        context.delegate.previewingContext(context, commitViewController: targetViewController)
        peekPopRelease()
    }
    
    func peekPopRelease() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.peekPopWindow?.alpha = 0.0
            }) { (finished) -> Void in
                self.peekPopGestureRecognizer?.resetValues()
                self.peekPopWindow?.hidden = true
                self.peekPopView?.removeFromSuperview()
                self.peekPopView = nil
        }
    }
    
}

public struct PreviewingContext {
    public let delegate: PeekPopPreviewingDelegate
    public let sourceView: UIView
}


public protocol PeekPopPreviewingDelegate {
    // If you return nil, a preview presentation will not be performed
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController?
    func previewingContext(previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController)
}
