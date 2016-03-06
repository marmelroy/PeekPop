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
    
    let timerLowerThreshold = 0.4
    let timerMaxThreshold = 4.0
    
    var target: PeekPop?
    var forceValue: Double = 0.0
    var initialMajorRadius: CGFloat?
    
    var holdValue: Bool = false
    
    var timer: NSTimer?
    var timerStart: NSDate?

    var traitCollection: UITraitCollection?
    var sourceView: UIView?

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
                    initialMajorRadius = touch.majorRadius
                    startTimers()
                }
            }
            else {
                initialMajorRadius = touch.majorRadius
                startTimers()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
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
        guard let initialMajorRadius = initialMajorRadius, firstThreshold = target?.thresholds.first,  targetValue = target?.thresholds[1] else {
            return
        }
        if initialMajorRadius/majorRadius < 0.9  {
            if forceValue < targetValue && forceValue > firstThreshold {
                forceValue = targetValue
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        super.touchesEnded(touches, withEvent: event)
        self.invalidateTimers()
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        self.invalidateTimers()
    }
    
    private func startTimers() {
        timerStart = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "longPress", userInfo: nil, repeats: true)
    }
    
    private func invalidateTimers() {
        if forceValue != 0.0 {
            forceValue = 0.0
            target?.peekPopRelease()
        }
        timer?.invalidate()
        timer = nil
        timerStart = nil
    }
    
    private func handleTouch(touch: UITouch)
    {
        if #available(iOS 9.0, *) {
            self.invalidateTimers()
            let forcePercentage = touch.force/touch.maximumPossibleForce
            handleForce(Double(forcePercentage))
        }
    }
    
    func isTouchValid(touch: UITouch) -> Bool {
        let sourceRect = sourceView?.frame ?? CGRect.zero
        return CGRectContainsPoint(sourceRect, touch.locationInView(self.view))
    }
    
    func longPress() {
        let timerValue = timerStart?.timeIntervalSinceNow ?? 0.0
        let timeInterval = abs(timerValue)
        if timeInterval > timerLowerThreshold && holdValue == false {
            let timerAddition = 0.1/(timerMaxThreshold-timerLowerThreshold)
            let force = min(forceValue + timerAddition, 1.0)
            handleForce(force)
        }
    }
    
    private func handleForce(force: Double)
    {
        if force == 0 {
            return
        }
        self.forceValue = force
        target?.peekPopAnimate(force)
    }

}
