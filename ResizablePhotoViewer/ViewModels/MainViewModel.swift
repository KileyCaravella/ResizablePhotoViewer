//
//  MainViewModel.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import UIKit

/*
 Main View Model:
 - Returns Both Pan Gesture Translation X value and CGPoint for changing Thumbnail view size and dragging an image
*/

class MainViewModel: NSObject {
    
    
    //MARK: - Variables
    
    var lastPanTranslation: CGFloat = 0
    var cellPanTranslationStartingPoint: CGPoint = CGPoint(x: 0, y: 0)
    var cellPanTranslationEndingPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    
    //MARK: - Pan Gesture Recognizer Functions
    
    func updateThumbnailWidthConstraint(withRecognizer panRecognizer: UIPanGestureRecognizer, inView view: UIView) -> CGFloat {
        if panRecognizer.state == .began || panRecognizer.state == .changed {
            let newTranslation = panRecognizer.translation(in: view).x
            let xTranslation = (lastPanTranslation - newTranslation)
            lastPanTranslation = newTranslation
            return xTranslation
        } else {
            lastPanTranslation = 0.0
            return 0.0
        }
    }
    
    func updatePanningImageViewLocation(withRecognizer panRecognizer: UIPanGestureRecognizer, imageView: UIImageView, inView view: UIView) -> CGPoint? {
        let translation = panRecognizer.translation(in: view)
        let newTranslation =  CGPoint(x: cellPanTranslationStartingPoint.x + translation.x, y: cellPanTranslationStartingPoint.y + translation.y)
        
        if panRecognizer.state == .began || panRecognizer.state == .changed {
            return newTranslation
        } else {
            cellPanTranslationEndingPoint = newTranslation
            return nil
        }
    }
}
