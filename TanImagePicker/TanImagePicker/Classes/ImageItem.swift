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
        let isVideo: Bool
        private(set) var video: AVAsset?
        
        init(_ asset: PHAsset) {
            self.asset = asset
            isVideo = asset.mediaType == .video
            
            Me.ImagesManager.shared.fetchVideo(with: asset, progressHandler: nil) { [weak self] video in
                Me.mainQueue.async {
                    self?.video = video
                }
            }
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
    static func ==(lhs: TanImagePicker.ImageItem, rhs: TanImagePicker.ImageItem) -> Bool {
        return lhs.asset == rhs.asset
    }
    
    var hashValue: Int {
        return asset.hashValue
    }
}
