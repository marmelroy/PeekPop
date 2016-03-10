//
//  PeekPopView.swift
//  PeekPop
//
//  Created by Roy Marmelstein on 09/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

class PeekPopView: UIView {
    
    
    let blurFilter = CIFilter(name: "CIGaussianBlur")
    
    var viewControllerScreenshot: UIImage? = nil {
        didSet {
            blurredScreenshots.removeAll()
            generateScreenshots()
        }
    }

    var sourceViewRect = CGRect.zero
    var sourceViewScreenshot: UIImage?
    var blurredScreenshots = [UIImage]()

    var blurredLowestLevel = UIImageView()
    var blurredImageViewFirst = UIImageView()
    var blurredImageViewSecond = UIImageView()
    var overlayView = UIView()
    var sourceImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.frame = self.bounds
    }
    
    
    func setup() {
        self.addSubview(blurredLowestLevel)
        self.addSubview(blurredImageViewFirst)
        self.addSubview(blurredImageViewSecond)
        overlayView.backgroundColor = UIColor(white: 0.80, alpha: 0.5)
        self.addSubview(overlayView)
        self.addSubview(sourceImageView)
    }
    
    func didAppear() {
        blurredLowestLevel.frame = self.bounds
        blurredImageViewFirst.frame = self.bounds
        blurredImageViewSecond.frame = self.bounds
        sourceImageView.frame = sourceViewRect
    }
    
    func peekPopAnimate(progress: Double) {
        let adjustedProgress = min(progress*3,1.0)
        let blur = adjustedProgress*5.0
        let blurIndex = Int(blur)
        let blurRemainder = blur - Double(blurIndex)
        let adjustedScale: CGFloat = 1.0 - CGFloat(adjustedProgress)*0.02
        let adjustedSourceImageScale: CGFloat = 1.0 + CGFloat(adjustedProgress)*0.02
        blurredLowestLevel.image = blurredScreenshots.last
        blurredImageViewFirst.transform = CGAffineTransformMakeScale(adjustedScale, adjustedScale)
        blurredImageViewFirst.image = blurredScreenshots[blurIndex]
        blurredImageViewSecond.transform = CGAffineTransformMakeScale(adjustedScale, adjustedScale)
        blurredImageViewSecond.image = blurredScreenshots[blurIndex + 1]
        blurredImageViewSecond.alpha = CGFloat(blurRemainder)
        overlayView.alpha = CGFloat(adjustedProgress)
        sourceImageView.image = sourceViewScreenshot
        sourceImageView.transform = CGAffineTransformMakeScale(adjustedSourceImageScale, adjustedSourceImageScale)

    }
    
    func generateScreenshots() {
        print("generate screenshots")
        guard let viewControllerScreenshot = viewControllerScreenshot else {
            return
        }
        blurredScreenshots.append(viewControllerScreenshot)
        for i in 1...6 {
            let radius: CGFloat = CGFloat(Double(i) * 6.0 / 6.0)
            if let blurredScreenshot = blurScreenshotWithRadius(radius) {
                blurredScreenshots.append(blurredScreenshot)
            }
        }
    }
    
    func blurScreenshotWithRadius(radius: CGFloat) -> UIImage? {
        return viewControllerScreenshot?.applyBlurWithRadius(CGFloat(radius), tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)
    }
    
}
