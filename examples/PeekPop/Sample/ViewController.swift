//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 06/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import PeekPop

class ViewController: UIViewController, PeekPopPreviewingDelegate {

    var peekPop: PeekPop?
    
    @IBOutlet weak var touchArea: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: touchArea)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewControllerWithIdentifier("PreviewViewController") as? PreviewViewController {
            return previewViewController
        }
        return nil
    }
    
    func previewingContext(previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {
    }

}

