//
//  ViewController.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import UIKit
import Photos

/*
 Main View Controller:
 - Controls Communication between View Controllers
 - Controls ImageView when user selects an image
*/

class MainViewController: UIViewController {

    
    //MARK: - Variables
    
    @IBOutlet weak var thumbnailContainerView: UIView!
    @IBOutlet weak var detailConstainerView: UIView!
    @IBOutlet weak var historyContainerView: UIView!
    
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var historyWidthConstraint: NSLayoutConstraint!
    
    //Model and VC Variables
    var viewModel: MainViewModel = MainViewModel()
    var thumbnailVC: PhotoCollectionViewController?
    var detailVC: DetailViewController?
    var historyVC: PhotoCollectionViewController?
    
    //Panning Variables
    var panningImageView: UIImageView = UIImageView(frame: CGRect(x: -60, y: 0, width: 60, height: 60))
    var panningAsset: PHAsset = PHAsset()
    var _firstTimePanningOnCell: Bool = true
    var firstTimePanningOnCell: Bool {
        get { return _firstTimePanningOnCell }
        set (newBool) {
            panningImageView.isHidden = newBool
            _firstTimePanningOnCell = newBool
        }
    }
    
    var showHistory: Bool = false
    
    
    //MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(panningImageView)
        historyWidthConstraint.constant = CGFloat.leastNonzeroMagnitude
        view.backgroundColor = Constants.BLUE_BORDER_COLOR
        thumbnailVC?.delegate = self
        detailVC?.delegate = self
        historyVC?.delegate = self
    }
    
    
    //MARK: - Get Embedded View Controllers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
            case "thumbnailVC":     thumbnailVC = segue.destination as? PhotoCollectionViewController
            case "detailVC":        detailVC = segue.destination as? DetailViewController
            case "historyVC":       historyVC = segue.destination as? PhotoCollectionViewController
                                    historyVC?.showingHistory = true
            default:                break
        }
    }
}


//MARK: - Photo Collection View Controller Delegate

extension MainViewController: PhotoCollectionViewControllerDelegate {
    func didPanOnResizeButton(panRecognizer: UIPanGestureRecognizer, sender: PhotoCollectionViewController) {
        let offset = viewModel.updateThumbnailWidthConstraint(withRecognizer: panRecognizer, inView: self.view)
        if ((thumbnailWidthConstraint.constant - offset) < Constants.SMALLEST_VIEW_WIDTH) { return }
        thumbnailWidthConstraint.constant -= offset
        detailVC?.setupImageSize()
    }
    
    func didSelectAsset(asset: PHAsset, image: UIImage) {
        if historyVC?.viewModel.assets[safe: 0] != asset {
            historyVC?.viewModel.assets.insert(asset, at: 0)
            historyVC?.collectionView.reloadData()
        }
        
        detailVC?.image = image
        detailVC?.asset = asset
        detailVC?.setupView()
    }
    
    
    //MARK: - Panning on Cell
    
    func didPanOnCell(cell: PhotoCell, panRecognizer: UIPanGestureRecognizer) {
        panningImageView.image = cell.image ?? UIImage()
        panningAsset = cell.asset ?? PHAsset()
        
        if firstTimePanningOnCell {
            firstTimePanningOnCell = false
            setupPanningImageView(withImageView: cell.imageView)
            viewModel.cellPanTranslationStartingPoint = panRecognizer.location(in: self.view)
        }
        
        guard let newLocation = viewModel.updatePanningImageViewLocation(withRecognizer: panRecognizer, imageView: panningImageView, inView: view) else { stoppedPanning(); return}
        panningImageView.frame.origin = newLocation
    }
    
    func setupPanningImageView(withImageView imageView: UIImageView) {
        panningImageView.clipsToBounds = true
        panningImageView.layer.cornerRadius = 4
        panningImageView.image = imageView.image
        panningImageView.frame.size.height = panningImageView.frame.width * (imageView.frame.height/imageView.frame.width)
    }
    
    func stoppedPanning() {
        firstTimePanningOnCell = true
        if detailConstainerView.frame.contains(viewModel.cellPanTranslationEndingPoint) {
            didSelectAsset(asset: panningAsset, image: panningImageView.image ?? UIImage())
        }
    }
}


//MARK: - Detail View Controller Delegate

extension MainViewController: DetailViewControllerDelegate {
    func didPressHistoryButton(sender: DetailViewController) {
        showHistory = !showHistory
        
        UIView.animate(withDuration: 0.2) {
            self.historyWidthConstraint.constant = self.showHistory ? Constants.SMALLEST_VIEW_WIDTH : CGFloat.leastNonzeroMagnitude
            self.view.layoutIfNeeded()
            self.detailVC?.setupImageSize()
        }
    }
}
