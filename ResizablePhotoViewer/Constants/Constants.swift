//
//  Constants.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import UIKit

/*
 Constants
 - All Necessary Constants for Project
 - Returns size of phone based on phone's model
*/

class Constants {
    
    
    //MARK: - Colors
    
    static let BLUE_BACKGROUND: UIColor = UIColor(red: 113/255, green: 175/255, blue: 238/255, alpha: 1.0)
    static let BLUE_BORDER_COLOR: UIColor = UIColor(red: 100/255, green: 155/255, blue: 224/255, alpha: 1.0)
    
    
    //MARK: - View Controller Sizes
    
    static let SMALLEST_VIEW_WIDTH: CGFloat = 120
    
    
    //MARK: - Cell Identifiers
    
    static let PHOTO_CELL_IDENTIFIER: String = "PhotoCell"
    
    
    //MARK: - Device Size
    
    static var PHONE_SIZE: PhoneSize {
        get {
            switch UIDevice().type {
                case .iPod1, .iPod2, .iPod3, .iPod4, .iPod5, .iPhone4, .iPhone4S, .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE, .unrecognized: return .small
                case .iPhone6, .iPhone6S, .iPhone7, .iPhone8, .iPhoneX: return .normal
                default: return .large
            }
        }
    }
}
