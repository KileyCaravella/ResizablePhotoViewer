//
//  ThumbnailCell.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import UIKit
import Photos

/*
 Photo Cell:
 - Displays Image and Image's Information
 - Retrieves PHAsset Image Data if necessary from Photo Library
 */

protocol PhotoCellDelegate: class {
    func returnStoredImage(sender: PhotoCell) -> UIImage?
}

class PhotoCell: UICollectionViewCell {
    
    //MARK: - Variables
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageDescriptionLabel: UILabel!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: PhotoCellDelegate?
    weak var asset: PHAsset?
    
    var image: UIImage?
    var name: String?
    var size: String?
    var date: String?
    
    //MARK: - Setup Cell Functions
    
    func setupCell() {
        guard let asset = asset else { return }

        resetCellVariables()
        setupDescriptionLabel()
        setupCellSize()
        
        if image == nil {
            guard let retrievedImage = delegate?.returnStoredImage(sender: self) else { requestImageData(forAsset: asset); return}
            image = retrievedImage
            imageView.image = image
        }
    }
    
    func resetCellVariables() {
        image = nil
        name = nil
        size = nil
        date = nil
    }
    
    func setupDescriptionLabel() {
        if name == nil && size == nil {
            guard let asset = asset else { return }
            
            //Getting Name
            let resources = PHAssetResource.assetResources(for: asset)
            guard let resource = resources.first, let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong  else { return }
            name = resource.originalFilename
            
            //Getting Size
            let formatter: ByteCountFormatter = ByteCountFormatter()
            formatter.countStyle = .binary
            size = formatter.string(fromByteCount: Int64(bitPattern: UInt64(unsignedInt64)))
            
            //Getting Date
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            if let creationDate = asset.creationDate {
                date = dateFormatter.string(from: creationDate)
            }
        }
        
        imageDescriptionLabel.text = "\(name ?? "no name")\n\(size ?? "no size")\n\(date ?? "no date")"
        imageDescriptionLabel.sizeToFit()
    }
    
    func setupCellSize() {
        DispatchQueue.main.async {
            let ratio: CGFloat = CGFloat(self.asset?.pixelHeight ?? 0) / CGFloat(self.asset?.pixelWidth ?? 1)
            self.imageViewHeightConstraint.constant = self.imageView.frame.width * ratio
            self.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Getting Initial Image Data
    
    func requestImageData(forAsset asset: PHAsset) {
        PHImageManager.default().requestImageData(for: asset, options: nil) { data, _, _, info in
            guard let data = data, let image = UIImage(data: data)  else { return }
            DispatchQueue.main.async {
                self.image = image
                self.imageView.image = image
            }
        }
    }
}
