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
        self.collectionView!.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: collectionView!)
    }

    // MARK: UICollectionView DataSource and Delegate

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.image = images[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.view.bounds.size.width - 5*5)/4
        return CGSize(width: size, height: size)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController {
            self.navigationController?.pushViewController(previewViewController, animated: true)
            previewViewController.image = images[indexPath.item]
        }
    }
    
    // MARK: PeekPopPreviewingDelegate
    
    
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        if let previewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController {
            if let indexPath = collectionView!.indexPathForItem(at: location) {
                let selectedImage = images[indexPath.item]
                if let layoutAttributes = collectionView!.layoutAttributesForItem(at: indexPath) {
                    previewingContext.sourceRect = layoutAttributes.frame
                }
                previewViewController.image = selectedImage
                return previewViewController
            }

        }
        return nil
    }
    
    func previewingContext(_ previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }

    
    
}
