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
    private lazy var peekPopWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.windowLevel = UIWindowLevelAlert
        window.rootViewController = UIViewController()
        return window
    }()

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
        if let viewControllerScreenshot = viewController.view.screenshotView() {
            peekPopView?.viewControllerScreenshot = viewControllerScreenshot
            peekPopView?.blurredScreenshots = self.generateBlurredScreenshots(viewControllerScreenshot)
        }
        
        // Take source view screenshot
        let rect = viewController.view.convertRect(context.sourceRect, fromView: context.sourceView)
        peekPopView?.sourceViewScreenshot = viewController.view.screenshotView(true, rect: rect)
        peekPopView?.sourceViewRect = rect

        // Take target view controller screenshot
        targetVC.view.frame = viewController.view.bounds
        peekPopView?.targetViewControllerScreenshot = targetVC.view.screenshotView(false)
        targetViewController = targetVC
        
        return true
    }
    
    func generateBlurredScreenshots(image: UIImage) -> [UIImage] {
        var images = [UIImage]()
        images.append(image)
        for i in 1...3 {
            let radius: CGFloat = CGFloat(Double(i) * 8.0 / 3.0)
            if let blurredScreenshot = blurImageWithRadius(image, radius: radius) {
                images.append(blurredScreenshot)
            }
        }
        return images
    }
    
    func blurImageWithRadius(image: UIImage, radius: CGFloat) -> UIImage? {
        return image.applyBlurWithRadius(CGFloat(radius), tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)
    }

    
    /// Add window to heirarchy when peek pop begins
    func peekPopBegan() {
        peekPopWindow.alpha = 0.0
        peekPopWindow.hidden = false
        peekPopWindow.makeKeyAndVisible()
        
        if let peekPopView = peekPopView {
            peekPopWindow.addSubview(peekPopView)
        }
        
        peekPopView?.frame = viewController.view.bounds
        peekPopView?.didAppear()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.peekPopWindow.alpha = 1.0
        })
        
    }
    
    /**
     Animated progress for context
     
     - parameter progress: A value between 0.0 and 1.0
     - parameter context:  PreviewingContext
     */
    func animateProgressForContext(progress: CGFloat, context: PreviewingContext?) {
        (progress < 0.99) ? peekPopView?.animateProgress(progress) : commitTarget(context)
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
            self.peekPopWindow.alpha = 0.0
            }) { (finished) -> Void in
                self.peekPop.peekPopGestureRecognizer?.resetValues()
                self.peekPopWindow.hidden = true
                self.peekPopView?.removeFromSuperview()
                self.peekPopView = nil
        }
    }

}