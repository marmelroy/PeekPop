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
    
    var targetViewControllerScreenshot: UIImage? = nil

    var sourceViewRect = CGRect.zero
    var sourceViewScreenshot: UIImage?
    var blurredScreenshots = [UIImage]()

    var blurredLowestLevel = UIImageView()
    var blurredImageViewFirst = UIImageView()
    var blurredImageViewSecond = UIImageView()
    var overlayView = UIView()
    var sourceImageView = UIImageView()
    var targetPreviewView = PeekPopTargetPreviewView()


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
        self.addSubview(targetPreviewView)
    }
    
    func didAppear() {
        blurredLowestLevel.frame = self.bounds
        blurredImageViewFirst.frame = self.bounds
        blurredImageViewSecond.frame = self.bounds
        targetPreviewView.imageViewFrame = self.bounds
        targetPreviewView.frame.size = sourceViewRect.size
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
        if progress < 0.3 {
            sourceImageView.hidden = false
            sourceImageView.transform = CGAffineTransformMakeScale(adjustedSourceImageScale, adjustedSourceImageScale)
            targetPreviewView.hidden = true
        }
        else {
            if progress > 0.33 && progress < 0.55 {
                print("progress medium")
                targetPreviewView.hidden = false
                let targetAdjustedScale: CGFloat = min(CGFloat((progress - 0.33)/(0.55-0.33)), CGFloat(1.0))
                let sourceViewCenter = CGPointMake(sourceViewRect.origin.x + sourceViewRect.size.width/2, sourceViewRect.origin.y + sourceViewRect.size.height/2)
                let originXDelta = self.bounds.size.width/2 - sourceViewCenter.x
                let originYDelta = self.bounds.size.height/2 - sourceViewCenter.y
                let widthDelta = self.bounds.size.width - 32 - sourceViewRect.size.width
                let heightDelta = self.bounds.size.height - 120 - sourceViewRect.size.height
                targetPreviewView.imageView.image = targetViewControllerScreenshot
                targetPreviewView.frame.size = CGSizeMake(sourceViewRect.size.width + widthDelta*targetAdjustedScale, sourceViewRect.size.height + heightDelta*targetAdjustedScale)
                targetPreviewView.center = CGPointMake(sourceViewCenter.x + originXDelta*targetAdjustedScale, sourceViewCenter.y + originYDelta*targetAdjustedScale)
            }
            else if progress > 0.66 && progress < 0.95 {
                print("progress expands")
                let targetAdjustedScale = min(CGFloat(1 + (progress-0.66)/4),1.1)
                targetPreviewView.transform = CGAffineTransformMakeScale(targetAdjustedScale, targetAdjustedScale)
            }
            else if progress > 0.95{
                targetPreviewView.frame = self.bounds
                targetPreviewView.layer.cornerRadius = 0
            }
            sourceImageView.hidden = true
        }
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

class PeekPopTargetPreviewView: UIView {
    
    var imageContainer = UIImageView()
    var imageView = UIImageView()
    var imageViewFrame = CGRect.zero

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
        imageContainer.frame = self.bounds
        imageView.frame = imageViewFrame
        imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath;

    }
    
    
    func setup() {
        self.addSubview(imageContainer)
        imageContainer.layer.cornerRadius = 20
        imageContainer.clipsToBounds = true
        imageContainer.addSubview(imageView)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 5)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.4
    }
}



