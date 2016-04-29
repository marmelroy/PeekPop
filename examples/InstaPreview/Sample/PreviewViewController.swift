//
//  PreviewViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 13/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView?.image = image
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Amsterdam"
        imageView.image = image
        activityIndicator.startAnimating()
    }

}
