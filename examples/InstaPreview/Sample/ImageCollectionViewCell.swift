//
//  ImageCollectionViewCell.swift
//  Sample
//
//  Created by Roy Marmelstein on 13/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Setting up the view
    func setup() {
        self.addSubview(imageView)
    }

}
