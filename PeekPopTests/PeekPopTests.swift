//
//  PeekPopTests.swift
//  PeekPopTests
//
//  Created by Roy Marmelstein on 23/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import XCTest
@testable import PeekPop

class PeekPopTests: XCTestCase {
    
    func testGestureRecognizerProgressIncreases() {
        let fakeViewController = UIViewController()
        let peekPop = PeekPop(viewController: fakeViewController)
        let peekPopGestureRecognizer = PeekPopGestureRecognizer(peekPop: peekPop)
        peekPopGestureRecognizer.progress = 0.0
        peekPopGestureRecognizer.targetProgress = 1.0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            sleep(2)
            dispatch_sync(dispatch_get_main_queue(), {
                XCTAssertEqual(peekPopGestureRecognizer.progress, 1.0)
            })
        })
    }
    
    func testGestureRecognizerProgressDecrease() {
        let fakeViewController = UIViewController()
        let peekPop = PeekPop(viewController: fakeViewController)
        let peekPopGestureRecognizer = PeekPopGestureRecognizer(peekPop: peekPop)
        peekPopGestureRecognizer.progress = 1.0
        peekPopGestureRecognizer.targetProgress = 0.0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            sleep(2)
            dispatch_sync(dispatch_get_main_queue(), {
                XCTAssertEqual(peekPopGestureRecognizer.progress, 0.0)
            })
        })
    }

    
    
}
