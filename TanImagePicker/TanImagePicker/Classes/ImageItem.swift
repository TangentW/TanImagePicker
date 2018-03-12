//
//  ImageItem.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import Foundation
import Photos

extension TanImagePicker {
    final class ImageItem {
        let asset: PHAsset
        let assetType: AssetType
        
        init(_ asset: PHAsset) {
            self.asset = asset
            assetType = {
                if asset.mediaType == .video {
                    return .video
                }
                
                if #available(iOS 9.1, *), asset.mediaSubtypes == .photoLive {
                    return .livePhoto
                }
                return .normal
            }()
        }
        
        // Status
        var isSelected = false {
            didSet {
                selectedStateCallback?(isSelected)
            }
        }
        
        var canSelected = true {
            didSet {
                canSelectedCallback?(canSelected)
            }
        }
        
        // Callbacks
        weak var bindedCell: ImageCell?
        var selectedStateCallback: ((Bool) -> ())?
        var canSelectedCallback: ((Bool) -> ())?
    }
}

extension TanImagePicker.ImageItem: Hashable {
    static func ==(lhs: Me.ImageItem, rhs: Me.ImageItem) -> Bool {
        return lhs.asset == rhs.asset
    }
    
    var hashValue: Int {
        return asset.hashValue
    }
}

extension TanImagePicker.ImageItem {
    enum AssetType {
        case normal // Image
        case video
        case livePhoto
    }
}
