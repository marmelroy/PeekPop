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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, let context = context, isTouchValid(touch)
        {
            let touchLocation = touch.location(in: self.view)
            self.state = (context.delegate?.previewingContext(context, viewControllerForLocation: touchLocation) != nil) ? .possible : .failed
            if self.state == .possible {
                self.perform(#selector(delayedFirstTouch), with: touch, afterDelay: 0.2)
            }
        }
        else {
            self.state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesMoved(touches, with: event)
        if(self.state == .possible){
            self.cancelTouches()
        }
        if let touch = touches.first, peekPopStarted == true
        {
            testForceChange(touch.majorRadius)
        }
    }
    
    func delayedFirstTouch(_ touch: UITouch) {
        if isTouchValid(touch) {
            self.state = .began
            if let context = context {
                let touchLocation = touch.location(in: self.view)
                _ = peekPopManager.peekPopPossible(context, touchLocation: touchLocation)
            }
            peekPopStarted = true
            initialMajorRadius = touch.majorRadius
            peekPopManager.peekPopBegan()
            targetProgress = previewThreshold
        }
    }
    
    func testForceChange(_ majorRadius: CGFloat) {
        if initialMajorRadius/majorRadius < 0.6  {
            targetProgress = 0.99
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent)
    {
        self.cancelTouches()
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.cancelTouches()
        super.touchesCancelled(touches, with: event)
    }
    
    func resetValues() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        peekPopStarted = false
        progress = 0.0
    }
    
    fileprivate func cancelTouches() {
        self.state = .cancelled
        peekPopStarted = false
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if progress < commitThreshold {
            targetProgress = 0.0
        }
    }
    
    func isTouchValid(_ touch: UITouch) -> Bool {
        let sourceRect = context?.sourceView.frame ?? CGRect.zero
        let touchLocation = touch.location(in: self.view?.superview)
        return sourceRect.contains(touchLocation)
    }
    
    func updateProgress() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(animateToTargetProgress))
        displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
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
