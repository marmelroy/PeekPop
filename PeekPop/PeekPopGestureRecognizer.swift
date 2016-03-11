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
    
    var thresholds = [0.33, 0.66, 1.0]
    
    var interpolationStep = 0.006

    var target: PeekPop?
    
    var forceValue: Double = 0.0 {
        didSet {
            target?.peekPopAnimate(forceValue, context: context)
        }
    }
    
    var targetForceValue: Double = 0.0 {
        didSet {
            animateToTargetForce()
        }
    }

    var currentThresholdIndex = 0
    
    var initialMajorRadius: CGFloat?
    
    var traitCollection: UITraitCollection?
    var context: PreviewingContext?
    
    var displayLink: CADisplayLink?

    override required init(target: AnyObject?, action: Selector)
    {
        super.init(target: target, action: action)
        if let peekPopTarget = target as? PeekPop {
            self.target = peekPopTarget
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        if let touch = touches.first where isTouchValid(touch)
        {
            if #available(iOS 9.0, *) {
                if traitCollection?.forceTouchCapability == UIForceTouchCapability.Available && TARGET_OS_SIMULATOR != 1 {
                    handleTouch(touch)
                }
                else {
                    self.performSelector("delayedFirstTouch:", withObject: touch, afterDelay: 0.25)
                }
            }
            else {
                self.performSelector("delayedFirstTouch:", withObject: touch, afterDelay: 0.25)
            }
        }
    }
    
    func delayedFirstTouch(touch: UITouch) {
        initialMajorRadius = touch.majorRadius
        longPress()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first
        {
            if #available(iOS 9.0, *) {
                if traitCollection?.forceTouchCapability == UIForceTouchCapability.Available && TARGET_OS_SIMULATOR != 1 {
                    handleTouch(touch)
                }
                else {
                    testMajorRadiusChange(touch.majorRadius)
                }
            }
            else {
                testMajorRadiusChange(touch.majorRadius)
            }
        }
    }
    
    func testMajorRadiusChange(majorRadius: CGFloat) {
        guard let initialMajorRadius = initialMajorRadius else {
            return
        }
        print("MAJOR RADIUS initial \(initialMajorRadius), current MAJOR \(majorRadius)")

        if initialMajorRadius/majorRadius < 0.5  {
            print("hard")
            interpolationStep = 0.03
        }
        else {
            print("soft")
            interpolationStep = 0.006
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesEnded(touches, withEvent: event)
        self.cancelTouches()
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        self.cancelTouches()
    }
    
    func resetValues() {
        forceValue = 0.0
        currentThresholdIndex = 0
        interpolationStep = 0.006
    }
    
    private func cancelTouches() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        if forceValue < 0.98 {
            targetForceValue = 0.0
            currentThresholdIndex = 0
        }
    }
    
    private func handleTouch(touch: UITouch)
    {
        if #available(iOS 9.0, *) {
            self.cancelTouches()
            let forcePercentage = touch.force/touch.maximumPossibleForce
            targetForceValue = Double(forcePercentage)
        }
    }
    
    func isTouchValid(touch: UITouch) -> Bool {
        let sourceRect = context?.sourceView.frame ?? CGRect.zero
        let touchLocation = touch.locationInView(self.view)
        if let context = context {
            target?.targetViewController = context.delegate.previewingContext(context, viewControllerForLocation: touchLocation)
        }
        return CGRectContainsPoint(sourceRect, touchLocation)
    }
    
    func longPress() {
        targetForceValue = 0.99
    }
    
    func animateToTargetForce() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: "updateForceToTarget")
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func updateForceToTarget() {
        let isIncrease = (forceValue < targetForceValue)
        if isIncrease {
            forceValue = min(forceValue + interpolationStep, targetForceValue)
            if forceValue >= targetForceValue {
                displayLink?.invalidate()
            }
        }
        else {
            forceValue = max(forceValue - interpolationStep*2, targetForceValue)
            if forceValue <= targetForceValue {
                forceValue = 0.0
                displayLink?.invalidate()
                target?.peekPopRelease()
            }
        }
    }
    
}
