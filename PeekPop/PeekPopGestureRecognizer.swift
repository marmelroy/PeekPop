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
    
    let timerLowerThreshold = 0.3
    let timerMaxThreshold = 2.5
    
    var target: PeekPop?
    
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
                if traitCollection?.forceTouchCapability != UIForceTouchCapability.Available {
                    handleTouch(touch)
                    startTimers()
                }
            }
            else {
                startTimers()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent)
    {
        if let touch = touches.first
        {
            handleTouch(touch)
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
        timer?.invalidate()
        timer = nil
        timerStart = nil
    }
    
    private func handleTouch(touch: UITouch)
    {
        if #available(iOS 9.0, *) {
            if traitCollection?.forceTouchCapability == UIForceTouchCapability.Available {
                let forcePercentage = touch.force/touch.maximumPossibleForce
                handleForce(Double(forcePercentage))
            }
        }
    }
    
    func isTouchValid(touch: UITouch) -> Bool {
        let sourceRect = sourceView?.frame ?? CGRect.zero
        return CGRectContainsPoint(sourceRect, touch.locationInView(self.view))
    }
    
    func longPress() {
        let timerValue = timerStart?.timeIntervalSinceNow ?? 0.0
        let timeInterval = abs(timerValue)
        var forceValue = 0.0
        if timeInterval > timerLowerThreshold {
            forceValue = (timeInterval-timerLowerThreshold)/(timerMaxThreshold-timerLowerThreshold)
            if timeInterval > timerMaxThreshold {
                forceValue = 1.0
            }
        }
        handleForce(forceValue)
    }
    
    private func handleForce(force: Double)
    {
        if force == 0 {
            return
        }
        target?.animatePeekPop(force)
    }

}
