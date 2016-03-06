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
    public func registerForPreviewingWithDelegate(delegate: PeekPopPreviewingDelegate, sourceView: UIView) -> PreviewingContext {
        return PreviewingContext(delegate: delegate, sourceView: sourceView, sourceRect: sourceView.frame)
    }
    
    // Unregisters a view controller to participate with 3D Touch preview (peek) and commit (pop).
    public func unregisterForPreviewingWithContext(previewing: PreviewingContext) {
    }

}

public struct PreviewingContext {
    public let delegate: PeekPopPreviewingDelegate
    public let sourceView: UIView
    public let sourceRect: CGRect
}


public protocol PeekPopPreviewingDelegate {
    // If you return nil, a preview presentation will not be performed
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController?
    func previewingContext(previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController)
}
