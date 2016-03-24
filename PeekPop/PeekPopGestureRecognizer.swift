//
//  PeekPopGestureRecognizer.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 06/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class PeekPopGestureRecognizer: UIGestureRecognizer
{
    
    var context: PreviewingContext?
    let peekPopManager: PeekPopManager
    
    let interpolationSpeed: CGFloat = 0.02
    let previewThreshold: CGFloat = 0.66
    let commitThreshold: CGFloat = 0.99
    
    var progress: CGFloat = 0.0
    var targetProgress: CGFloat = 0.0 {
        didSet { updateProgress() }
    }
    
    var initialMajorRadius: CGFloat = 0.0
    var displayLink: CADisplayLink?
    
    var peekPopStarted = false
    
    //MARK: Lifecycle
    
    init(peekPop: PeekPop) {
        self.peekPopManager = PeekPopManager(peekPop: peekPop)
        super.init(target: nil, action: nil)
    }
    
    //MARK: Touch handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first, context = context where isTouchValid(touch)
        {
            let touchLocation = touch.locationInView(self.view)
            self.state = (context.delegate.previewingContext(context, viewControllerForLocation: touchLocation) != nil) ? .Possible : .Failed
            if self.state == .Possible {
                self.performSelector(#selector(delayedFirstTouch), withObject: touch, afterDelay: 0.2)
            }
        }
        else {
            self.state = .Failed
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first where peekPopStarted == true
        {
            testForceChange(touch.majorRadius)
        }
    }
    
    func delayedFirstTouch(touch: UITouch) {
        if isTouchValid(touch) {
            self.state = .Began
            if let context = context {
                let touchLocation = touch.locationInView(self.view)
                peekPopManager.peekPopPossible(context, touchLocation: touchLocation)
            }
            peekPopStarted = true
            initialMajorRadius = touch.majorRadius
            peekPopManager.peekPopBegan()
            targetProgress = previewThreshold
        }
    }
    
    func testForceChange(majorRadius: CGFloat) {
        if initialMajorRadius/majorRadius < 0.6  {
            targetProgress = 0.99
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        self.cancelTouches()
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.cancelTouches()
        super.touchesCancelled(touches, withEvent: event)
    }
    
    func resetValues() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        peekPopStarted = false
        progress = 0.0
    }
    
    private func cancelTouches() {
        self.state = .Cancelled
        peekPopStarted = false
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        if progress < commitThreshold {
            targetProgress = 0.0
        }
    }
    
    func isTouchValid(touch: UITouch) -> Bool {
        let sourceRect = context?.sourceView.frame ?? CGRect.zero
        let touchLocation = touch.locationInView(self.view?.superview)
        return CGRectContainsPoint(sourceRect, touchLocation)
    }
    
    func updateProgress() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(animateToTargetProgress))
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func animateToTargetProgress() {
        if progress < targetProgress {
            progress = min(progress + interpolationSpeed, targetProgress)
            if progress >= targetProgress {
                displayLink?.invalidate()
            }
        }
        else {
            progress = max(progress - interpolationSpeed*2, targetProgress)
            if progress <= targetProgress {
                progress = 0.0
                displayLink?.invalidate()
                peekPopManager.peekPopEnded()
            }
        }
        peekPopManager.animateProgressForContext(progress, context: context)
    }
    
}
