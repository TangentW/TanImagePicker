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
        
        private var _video: AVAsset?
        private var _videoRequestID: PHImageRequestID?
        
        init(_ asset: PHAsset) {
            self.asset = asset
            isVideo = asset.mediaType == .video
        }
        
        deinit {
            cancelVideoDownloading()
        }
        
        func downloadVideoIfHas() {
            guard isVideo, _videoRequestID == nil else { return }
            if let video = _video {
                videoDownloadingStateCallback?(.completed(video)); return
            }
            _videoRequestID = Me.ImagesManager.shared.fetchVideo(with: asset, progressHandler: { [weak self] progress, _ in
                Me.mainQueue.async {
                    self?.videoDownloadingStateCallback?(.progress(progress))
                }
            }, completionHandler: { [weak self] video in
                Me.mainQueue.async {
                    self?._video = video
                    self?.videoDownloadingStateCallback?(.completed(video))
                }
            })
        }
        
        func cancelVideoDownloading() {
            guard let requestID = _videoRequestID else { return }
            PHImageManager.default().cancelImageRequest(requestID)
            videoDownloadingStateCallback?(.cancel)
            _videoRequestID = nil
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
        var videoDownloadingStateCallback: DownloadingStateCallback<AVAsset>?
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
