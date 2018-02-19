//
//  DetailViewController.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import UIKit
import Photos

/*
 Detail View Controller:
 - Displays the most recently-selected image
 - Contains button to toggle history view side panel
*/

protocol DetailViewControllerDelegate: class {
    func didPressHistoryButton(sender: DetailViewController)
}

class DetailViewController: UIViewController {
    
    
    //MARK: - Variables
    
    @IBOutlet weak var topBar: UIView?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageDescriptionLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: DetailViewControllerDelegate?
    var image: UIImage = UIImage()
    var asset: PHAsset?
    
    
    //MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        historyButton.isHidden = Constants.PHONE_SIZE != .large
        topBar?.backgroundColor = Constants.BLUE_BACKGROUND
    }
    
    func setupView() {
        setupImageSize()
        setupImageView()

        guard let asset = asset else { return }
        
        //Retrieving Name
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first, let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong  else { return }
        let name = resource.originalFilename
        
        //Retrieving Size
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        let size = formatter.string(fromByteCount: Int64(bitPattern: UInt64(unsignedInt64)))
    
        //Retrieving Date
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var date: String?
        if let creationDate = asset.creationDate {
            date = dateFormatter.string(from: creationDate)
        }
        
        imageDescriptionLabel.text = "\(name)\n\(size)\n\(date ?? "no date")"
        imageDescriptionLabel.sizeToFit()
    }
    
    func setupImageView() {
        imageView.image = image
        
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
        view.isUserInteractionEnabled = true
    }
    
    func setupImageSize(fromDropInteraction: Bool = false) {
        var ratio: CGFloat
        if fromDropInteraction {
            ratio = (image.size.height) / (image.size.width)
        } else {
            ratio = CGFloat(asset?.pixelHeight ?? 0) / CGFloat(asset?.pixelWidth ?? 1)
        }
        
        imageViewWidthConstraint.constant = view.frame.width
        imageViewHeightConstraint.constant = view.frame.width * ratio
        view.sizeToFit()
    }
    
    
    //Mark: - Action Functions
    
    @IBAction func historyButtonPressed(_ sender: UIButton) {
        delegate?.didPressHistoryButton(sender: self)
    }
}

extension DetailViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { imageItems in
            guard let images = imageItems as? [UIImage] else { return }
            self.image = images.first ?? self.image
            self.imageView.image = self.image
            self.setupImageSize(fromDropInteraction: true)
            self.imageDescriptionLabel.text = "Dropped In!\nNo Information Available."
        }
    }
}
