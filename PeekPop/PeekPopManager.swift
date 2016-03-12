//
//  PeekPopManager.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 12/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

class PeekPopManager {
    
    let peekPop: PeekPop
    
    var viewController: UIViewController { get {return peekPop.viewController} }
    var targetViewController: UIViewController?
    
    private var peekPopView: PeekPopView?
    private var peekPopWindow: UIWindow?

    init(peekPop: PeekPop) {
        self.peekPop = peekPop
    }
    
    func peekPopPossible(context: PreviewingContext, touchLocation: CGPoint) -> Bool {
        
        // Return early if no target view controller is provided by delegate method
        guard let targetVC = context.delegate.previewingContext(context, viewControllerForLocation: touchLocation) else {
            return false
        }
        
        // Create PeekPopView
        let view = PeekPopView()
        peekPopView = view
        
        // Take view controller screenshot
        peekPopView?.viewControllerScreenshot = viewController.view.screenshotView()
        
        // Take source view screenshot
        peekPopView?.sourceViewScreenshot = context.sourceView.screenshotView()
        peekPopView?.sourceViewRect = viewController.view.convertRect(context.sourceView.frame, toView: viewController.view)
        
        // Take target view controller screenshot
        targetVC.view.frame = viewController.view.bounds
        peekPopView?.targetViewControllerScreenshot = targetVC.view.screenshotView(false)
        targetViewController = targetVC
        
        return true
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
                self.peekPop.peekPopGestureRecognizer?.resetValues()
                self.peekPopWindow?.hidden = true
                self.peekPopView?.removeFromSuperview()
                self.peekPopView = nil
        }
    }

}