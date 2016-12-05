//
//  PeekPop.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 06/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

/// PeekPop class
open class PeekPop: NSObject {
    
    //MARK: Variables
    fileprivate var previewingContexts = [PreviewingContext]()
    
    internal var viewController: UIViewController
    internal var peekPopGestureRecognizer: PeekPopGestureRecognizer?
    
    /// Fallback to Apple's peek and pop implementation for devices that support it.
    fileprivate var forceTouchDelegate: ForceTouchDelegate?
    
    //MARK: Lifecycle
    
    /**
    Peek pop initializer
     
     - parameter viewController: hosting UIViewController
     
     - returns: PeekPop object
     */
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    //MARK: Delegate registration
    
    /// Registers a view controller to participate with 3D Touch preview (peek) and commit (pop).
    open func registerForPreviewingWithDelegate(_ delegate: PeekPopPreviewingDelegate, sourceView: UIView) -> PreviewingContext {
        let previewing = PreviewingContext(delegate: delegate, sourceView: sourceView)
        previewingContexts.append(previewing)
        
        // If force touch is available, use Apple's implementation. Otherwise, use PeekPop's.
        if isForceTouchCapable() {
            let delegate = ForceTouchDelegate(delegate: delegate)
            delegate.registerFor3DTouch(sourceView, viewController: viewController)
            forceTouchDelegate = delegate
        }
        else {
            let gestureRecognizer = PeekPopGestureRecognizer(peekPop: self)
            gestureRecognizer.context = previewing
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delaysTouchesBegan = true
            gestureRecognizer.delegate = self
            sourceView.addGestureRecognizer(gestureRecognizer)
            peekPopGestureRecognizer = gestureRecognizer
        }
        
        return previewing
    }
        
    /// Check whether force touch is available
    func isForceTouchCapable() -> Bool {
        if #available(iOS 9.0, *) {
            return (self.viewController.traitCollection.forceTouchCapability == UIForceTouchCapability.available && TARGET_OS_SIMULATOR != 1)
        }
        return false
    }
    
}

/// Previewing context struct
open class PreviewingContext {
    /// Previewing delegate
    open weak var delegate: PeekPopPreviewingDelegate?
    /// Source view
    open let sourceView: UIView
    /// Source rect
    open var sourceRect: CGRect
    
    init(delegate: PeekPopPreviewingDelegate, sourceView: UIView) {
        self.delegate = delegate
        self.sourceView = sourceView
        self.sourceRect = sourceView.frame
    }
}


/// Peek pop previewing delegate
public protocol PeekPopPreviewingDelegate: class {
    
    /// Provide view controller for previewing context in location. If you return nil, a preview presentation will not be performed.
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController?
    
    /// Commit view controller when preview is committed.
    func previewingContext(_ previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController)
}

