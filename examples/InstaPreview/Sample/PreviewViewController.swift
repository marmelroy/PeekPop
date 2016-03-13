//
//  PreviewViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 13/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    var imageView = UIImageView()
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.frame = self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Amsterdam"
        imageView.image = image
        self.view.addSubview(imageView)
    }

}
