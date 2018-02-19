//
//  ThumbnailViewController.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import UIKit
import Photos

/*
 Photo Collection View Controller:
 - Controls Collection View as its delegate
 - Handles pan gesture on resizing view (if necessary)
 - Controls both Thumbnail Collection View and History Collection View (left and right views)
 - Displays Alerts sent from View Model
*/

protocol PhotoCollectionViewControllerDelegate: class {
    func didPanOnResizeButton(panRecognizer: UIPanGestureRecognizer, sender: PhotoCollectionViewController)
    func didSelectAsset(asset: PHAsset, image: UIImage)
    func didPanOnCell(cell: PhotoCell, panRecognizer: UIPanGestureRecognizer)
}

class PhotoCollectionViewController: UIViewController {
    
    
    //MARK: - Variables
    
    @IBOutlet weak var topBar: UIView?
    @IBOutlet weak var resizeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientView: UIView!
    
    weak var delegate: PhotoCollectionViewControllerDelegate?
    
    var showingHistory: Bool = false
    let viewModel: PhotoCollectionViewModel = PhotoCollectionViewModel()
    
    
    //MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(collectionView)
        setupPanGesture(resizeButton, action: #selector(PhotoCollectionViewController.panButton(_:)))
        setup(topBar, withBackgroundColor: Constants.BLUE_BACKGROUND)
        resizeButton.isHidden = showingHistory
        viewModel.delegate = self
        
        if !showingHistory {
            viewModel.setupPhotoAuthorization()
        }
    }
    
    func setup(_ view: UIView?, withBackgroundColor backgroundColor: UIColor = .clear) {
        view?.backgroundColor = backgroundColor
    }
    
    func setup(_ collectionView: UICollectionView?) {
        collectionView?.delegate = self
        collectionView?.dataSource = viewModel
        collectionView?.setCollectionViewLayout(viewModel.layout, animated: false)
    }
    
    func setupPanGesture(_ view: UIView, action: Selector) {
        let pan = UIPanGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(pan)
    }
    
    
    //MARK: - Pan Gesture Functions
    
    @objc func panButton(_ sender: UIPanGestureRecognizer){
        delegate?.didPanOnResizeButton(panRecognizer: sender, sender: self)
    }
}


//MARK: Collection View Delegate

extension PhotoCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return }
        delegate?.didSelectAsset(asset: cell.asset ?? PHAsset(), image: cell.image ?? UIImage())
    }
}


//MARK: - Photo Collection VM Delegate

extension PhotoCollectionViewController: PhotoCollectionViewModelDelegate {
    
    func showAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didPanOnCell(cell: PhotoCell, panRecognizer: UIPanGestureRecognizer, sender: PhotoCollectionViewModel) {
        delegate?.didPanOnCell(cell: cell, panRecognizer: panRecognizer)
    }
}
