//
//  Collection+SaveIndexOutOfRange.swift
//  ResizablePhotoViewer
//
//  Created by Kiley Caravella on 2/18/18.
//  Copyright © 2018 Kiley Caravella. All rights reserved.
//

import Photos

/*
 Array + Safe Index Out Of Range
 - Prevents Index Out Of Range Exception by returning nil if the element does not exist
*/

extension Array {
    subscript (safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}
