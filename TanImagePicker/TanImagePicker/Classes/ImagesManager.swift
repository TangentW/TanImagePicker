//
//  ImagesManager.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit
import Photos

// MARK: - PhotosManager
public extension TanImagePicker {
    final class ImagesManager {
        public static let shared = ImagesManager()
        private init() { }
    }
}

// For Photos
public extension TanImagePicker.ImagesManager {
    // ResultImage
    typealias ImageRequestCompletionHandler = (UIImage) -> ()
    // Progress, Stop
    typealias DownloadProgressHandler = (Double, UnsafeMutablePointer<ObjCBool>) -> ()
    // videoAsset
    typealias VideoRequestCompletionHandler = (AVAsset) -> ()
    
    @discardableResult
    func fetchImage(with asset: PHAsset,
                    type: ImageFetchType,
                    isSynchronous: Bool = false,
                    progressHandler: DownloadProgressHandler? = nil, // Called not in main thread!
        completionHandler: @escaping ImageRequestCompletionHandler) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.isSynchronous = isSynchronous
        option.progressHandler = { progress, _, stop, _ in
            progressHandler?(progress, stop)
        }
        let targetSize: CGSize
        switch type {
        case .thumbnail(let size):
            let scale = UIScreen.main.scale
            targetSize = CGSize(width: size.width * scale, height: size.height * scale)
            option.resizeMode = .fast
            option.deliveryMode = .opportunistic
            option.isNetworkAccessAllowed = true
        case .original:
            option.deliveryMode = .highQualityFormat
            option.isNetworkAccessAllowed = true
            targetSize = PHImageManagerMaximumSize
        }
        
        if asset.representsBurst {
            return PHImageManager.default().requestImageData(for: asset, options: option, resultHandler: { data, _, _, info in
                guard let info = info else { return }
                let fetchSucceed = !(info[PHImageCancelledKey] as? Bool ?? false) && info[PHImageErrorKey] == nil
                guard let data = data, let image = UIImage(data: data), fetchSucceed else { return }
                if targetSize != PHImageManagerMaximumSize {
                    if let retImage = image.scaleTo(size: targetSize) {
                        completionHandler(retImage)
                    }
                } else {
                    completionHandler(image)
                }
            })
        } else {
            return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: option, resultHandler: { image, info in
                guard let info = info else { return }
                let fetchSucceed = !(info[PHImageCancelledKey] as? Bool ?? false) && info[PHImageErrorKey] == nil
                guard let image = image, fetchSucceed else { return }
                completionHandler(image)
            })
        }
    }
}

// For Video
public extension TanImagePicker.ImagesManager {
    @discardableResult
    func fetchVideo(with asset: PHAsset, // Media type must be video, This function do not judge.
        progressHandler: DownloadProgressHandler?,
        completionHandler: @escaping VideoRequestCompletionHandler) -> PHImageRequestID? {
        let option = PHVideoRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.progressHandler = { progress, _, stop, _ in
            progressHandler?(progress, stop)
        }
        return PHImageManager.default().requestAVAsset(forVideo: asset, options: option, resultHandler: { avAsset, _, _ in
            if let avAsset = avAsset {
                completionHandler(avAsset)
            }
        })
    }
}

public extension TanImagePicker.ImagesManager {
    enum ImageFetchType {
        case thumbnail(size: CGSize)
        case original
    }
}

extension TanImagePicker.ImagesManager {
    func fetchRecentAssets(mediaOption: Me.MediaOption = .all, limit: Int = 0) -> [PHAsset] {
        let fetchOption = PHFetchOptions()
        if let predicate = NSPredicate(mediaOption: mediaOption) {
            fetchOption.predicate = predicate
        }
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOption.sortDescriptors = [sortDescriptor]
        if limit > 0 {
            fetchOption.fetchLimit = limit
        }
        let results = PHAsset.fetchAssets(with: fetchOption)
        return results.objects(at: IndexSet(0 ..< results.count))
    }
}

fileprivate extension NSPredicate {
    convenience init?(mediaOption: Me.MediaOption) {
        switch mediaOption {
        case .photo:
            self.init(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        case .video:
            self.init(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        case .all:
            self.init(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        default:
            return nil
        }
    }
}
