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
    
    //MARK: PeekPop
    
    /// Prepare peek pop view if peek and pop gesture is possible
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
    
    /// Add window to heirarchy when peek pop begins
    func peekPopBegan() {
        
        // Create window if it doesn't already exist
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
    
    /**
     Animated progress for context
     
     - parameter progress: A value between 0.0 and 1.0
     - parameter context:  PreviewingContext
     */
    func animateProgressForContext(progress: CGFloat, context: PreviewingContext?) {
        (progress < 0.99) ? peekPopView?.peekPopAnimate(progress) : commitTarget(context)
    }
    
    /**
     Commit target.
     
     - parameter context: PreviewingContext
     */
    func commitTarget(context: PreviewingContext?){
        guard let targetViewController = targetViewController, context = context else {
            return
        }
        context.delegate.previewingContext(context, commitViewController: targetViewController)
        peekPopEnded()
    }
    
    /**
     Peek pop ended
     
     - parameter animated: whether or not window removal should be animated
     */
    func peekPopEnded() {
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