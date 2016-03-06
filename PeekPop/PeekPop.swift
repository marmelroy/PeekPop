//
//  PeekPop.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 06/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

public class PeekPop {
    
    var viewController: UIViewController
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // Registers a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func registerForPreviewingWithDelegate(delegate: UIViewControllerPeekPopDelegate, sourceView: UIView) {
        if #available(iOS 9.0, *) {
            if let systemDelegate = delegate as? UIViewControllerPreviewingDelegate {
                viewController.registerForPreviewingWithDelegate(systemDelegate, sourceView: sourceView)
            }
        }
    }
    
    // Unregisters a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func unregisterForPreviewingWithContext(previewing: UIViewControllerPeekPreviewing) {
        if #available(iOS 9.0, *) {
            if let systemPreviewing = previewing as? UIViewControllerPreviewing {
                viewController.unregisterForPreviewingWithContext(systemPreviewing)
            }
        }
    }

}

public protocol UIViewControllerPeekPopDelegate: NSObjectProtocol {
    func previewingContext(previewingContext: UIViewControllerPeekPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
    func previewingContext(previewingContext: UIViewControllerPeekPreviewing, commitViewController viewControllerToCommit: UIViewController)

}

public protocol UIViewControllerPeekPreviewing: NSObjectProtocol {
    
    // This gesture can be used to cause the previewing presentation to wait until one of your gestures fails or to allow simultaneous recognition during the initial phase of the preview presentation.
    var previewingGestureRecognizerForFailureRelationship: UIGestureRecognizer { get }
    
    var delegate: UIViewControllerPeekPopDelegate { get }
    var sourceView: UIView { get }
    
    // This rect will be set to the bounds of sourceView before each call to
    // -previewingContext:viewControllerForLocation:
    
    var sourceRect: CGRect { get set }
}