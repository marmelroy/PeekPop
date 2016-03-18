//
//  ImagesCollectionViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 13/03/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import PeekPop

private let reuseIdentifier = "ImageCollectionViewCell"

class ImagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PeekPopPreviewingDelegate {
    
    var peekPop: PeekPop?
    
    var images = [UIImage(named: "IMG_5441.JPG"), UIImage(named: "IMG_5311.JPG"), UIImage(named: "IMG_5291.JPG"), UIImage(named: "IMG_5290.JPG"), UIImage(named: "IMG_5155.JPG"), UIImage(named: "IMG_5153.JPG"), UIImage(named: "IMG_4976.JPG")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "InstaPreview"
        self.collectionView!.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: collectionView!)
    }

    // MARK: UICollectionView DataSource and Delegate

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.image = images[indexPath.item]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = (self.view.bounds.size.width - 5*5)/4
        return CGSizeMake(size, size)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewControllerWithIdentifier("PreviewViewController") as? PreviewViewController {
            self.navigationController?.pushViewController(previewViewController, animated: true)
            previewViewController.image = images[indexPath.item]
        }
    }
    
    // MARK: PeekPopPreviewingDelegate
    
    
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewControllerWithIdentifier("PreviewViewController") as? PreviewViewController {
            if let indexPath = collectionView!.indexPathForItemAtPoint(location) {
                let selectedImage = images[indexPath.item]
                if let layoutAttributes = collectionView!.layoutAttributesForItemAtIndexPath(indexPath) {
                    previewingContext.sourceRect = layoutAttributes.frame
                }
                previewViewController.image = selectedImage
                return previewViewController
            }

        }
        return nil
    }
    
    func previewingContext(previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }

    
    
}
