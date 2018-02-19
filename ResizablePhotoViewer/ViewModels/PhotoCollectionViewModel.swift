//
//  ThumbnailViewModel.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import UIKit
import Photos


/*
 Photo Collection View Model:
 - Retrieves PHAssets from Phone Library
 - Caches and Retrieves images from cached image array
 - Data Source for Collection View that displays photo cells
*/

protocol PhotoCollectionViewModelDelegate: class {
    func showAlert(alert: UIAlertController)
    func reloadCollectionView()
    func didPanOnCell(cell: PhotoCell, panRecognizer: UIPanGestureRecognizer, sender: PhotoCollectionViewModel)
}

class PhotoCollectionViewModel: NSObject {
    
    
    //MARK: - Variables
    
    weak var delegate: PhotoCollectionViewModelDelegate?
    var assets: [PHAsset] = []
    var cachedImageArray = [(indexPath: IndexPath, imagePath: String)]()

    
    //MARK: - Setting up and Retrieving Photos from Phone Library

    func setupPhotoAuthorization() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
                case .authorized:               self.retrievePhotos()
                case .denied, .restricted:      self.needPhotoPermissionsAlert()
                case .notDetermined:            break
            }
        }
    }
    
    func retrievePhotos() {
        assets = []
        
        //Converting PHFetchResult<PFAsset> to [PFAsset] to use safe subtypes
        let tempPhotos = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
        tempPhotos.enumerateObjects() { object, _, _ in
            self.assets.append(object)
        }
        
        self.delegate?.reloadCollectionView()
    }
    
    
    //MARK: - Saving and Retrieving Images from Cache
    
    func saveImage(indexPath: IndexPath, image: UIImage) {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imagePath = (documents as NSString).appendingPathComponent("\(indexPath.section)-\(indexPath.row)-cached.png")
        
        guard let imageData = UIImagePNGRepresentation(image), let url = URL(string: imagePath) else { return }
        
        do {
            try imageData.write(to: url, options: [])
            cachedImageArray.append((indexPath, imagePath))
        } catch let error {
            print("count not save image data: \(error)")
        }
    }
    
    func getImage(_ indexPath: IndexPath) -> UIImage? {
        let filteredCachedImages = cachedImageArray.filter({ $0.indexPath == indexPath })
        guard let firstItem = filteredCachedImages.first else { return nil }
        return UIImage(contentsOfFile: firstItem.imagePath)
    }
    
    
    //MARK: - Pan Gesture
    
    func setupPanGesture(_ view: UIView, action: Selector) {
        let pan = UIPanGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(pan)
    }
    
    @objc func panCell(_ panRecognizer: UIPanGestureRecognizer) {
        guard let cell = panRecognizer.view as? PhotoCell else { return }
        delegate?.didPanOnCell(cell: cell, panRecognizer: panRecognizer, sender: self)
    }
    
    
    //MARK: - Alerts and Alert Helper Functions
    
    func needPhotoPermissionsAlert() {
        let alert = UIAlertController(title: "Need Permission", message: "We need permission to access your photos! Please update your permissions settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Go To Settings", style: .default, handler: {_ in self.goToSettings() }))
        delegate?.showAlert(alert: alert)
    }
    
    func goToSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl, completionHandler: nil)
    }
}


//MARK: - Collection View Data Source

extension PhotoCollectionViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = assets[safe: UInt(indexPath.row)], let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.PHOTO_CELL_IDENTIFIER, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        
        cell.tag = indexPath.row
        cell.delegate = self
        cell.asset = asset
        cell.setupCell()
        
        setupPanGesture(cell, action: #selector(panCell(_:)))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell, let image = cell.imageView.image else { return }
        saveImage(indexPath: indexPath, image: image)
        cell.image = nil
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    //MARK: - Collection View Flow Layout
    
    public var layout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        return layout
    }
}


//MARK: - Photo Cell Delegate

extension PhotoCollectionViewModel: PhotoCellDelegate {
    func returnStoredImage(sender: PhotoCell) -> UIImage? {
        return getImage(IndexPath(row: sender.tag, section: 0))
    }
}
