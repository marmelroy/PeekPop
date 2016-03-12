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
    
    var interpolationSpeed = 0.02

    let peekPopManager: PeekPopManager
    
    var forceValue: Double = 0.0 {
        didSet {
            peekPopManager.peekPopAnimate(forceValue, context: context)
        }
    }
    
    var targetForceValue: Double = 0.0 {
        didSet {
            animateToTargetForce()
        }
    }

    var currentThresholdIndex = 0
    
    var initialMajorRadius: CGFloat?
    
    var context: PreviewingContext?
    
    var displayLink: CADisplayLink?
    
    init(peekPop: PeekPop) {
        self.peekPopManager = PeekPopManager(peekPop: peekPop)
        super.init(target: nil, action: nil)
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first, context = context where isTouchValid(touch)
        {
            let touchLocation = touch.locationInView(self.view)
            let peekPopPossible = peekPopManager.peekPopPossible(context, touchLocation: touchLocation)
            self.state = peekPopPossible ? .Possible : .Failed
            if peekPopPossible {
                self.performSelector("delayedFirstTouch:", withObject: touch, afterDelay: 0.2)
            }
        }
        else {
            self.state = .Failed
        }
    }
    
    func delayedFirstTouch(touch: UITouch) {
        self.state = .Began
        initialMajorRadius = touch.majorRadius
        longPress()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first where isTouchValid(touch)
        {
            testMajorRadiusChange(touch.majorRadius)
        }
    }
    
    func testMajorRadiusChange(majorRadius: CGFloat) {
        guard let initialMajorRadius = initialMajorRadius else {
            return
        }
        if initialMajorRadius/majorRadius < 0.5  {
            targetForceValue = 1.0
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
        forceValue = 0.0
        currentThresholdIndex = 0
    }
    
    private func cancelTouches() {
        self.state = .Cancelled
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        if forceValue < 0.98 {
            targetForceValue = 0.0
            currentThresholdIndex = 0
        }
    }
    
    func isTouchValid(touch: UITouch) -> Bool {
        let sourceRect = context?.sourceView.frame ?? CGRect.zero
        let touchLocation = touch.locationInView(self.view)
        return CGRectContainsPoint(sourceRect, touchLocation)
    }
    
    func longPress() {
        targetForceValue = 0.66
    }
    
    func animateToTargetForce() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: "updateForceToTarget")
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func updateForceToTarget() {
        let isIncrease = (forceValue < targetForceValue)
        if isIncrease {
            forceValue = min(forceValue + interpolationSpeed, targetForceValue)
            if forceValue >= targetForceValue {
                displayLink?.invalidate()
            }
        }
        else {
            forceValue = max(forceValue - interpolationSpeed*2, targetForceValue)
            if forceValue <= targetForceValue {
                forceValue = 0.0
                displayLink?.invalidate()
                peekPopManager.peekPopRelease()
            }
        }
    }
    
}
