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
        DispatchQueue.global(qos: .default).async(execute: {
            sleep(2)
            DispatchQueue.main.sync(execute: {
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
        DispatchQueue.global(qos: .default).async(execute: {
            sleep(2)
            DispatchQueue.main.sync(execute: {
                XCTAssertEqual(peekPopGestureRecognizer.progress, 0.0)
            })
        })
    }

    
    
}
