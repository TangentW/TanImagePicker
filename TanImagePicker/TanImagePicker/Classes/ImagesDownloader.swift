//
//  ImagesDownloader.swift
//  TanImagePicker
//
//  Created by Tangent on 20/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import Foundation
import Photos

extension TanImagePicker {
    final class ImagesDownloader {
        private var _cancel: DownloadingCancel?
        
        public func download(_ assets: [PHAsset], stateCallback: DownloadingStateCallback<[PHAsset]>?) {
            _cancel = assets._downloadAssets(stateCallback: stateCallback)
        }
        
        public func cancel() {
            _cancel?()
        }
        
        deinit { _cancel?() }
    }
}

fileprivate extension Array where Element == PHAsset {
    func _downloadAssets(stateCallback: Me.DownloadingStateCallback<[PHAsset]>?) -> Me.DownloadingCancel {
        assert(Thread.isMainThread, "This method must be called in main thread.")
        var isStopped = false
        let cancel = { isStopped = true; stateCallback?(.cancel) }
        var totalProgress: [PHAsset: Double] = [:]
        
        Me.inAsyncQueue {
            self.forEach { asset in
                asset._download(progressHandler: { progress, stop in
                    Me.inMainQueue {
                        if isStopped { stop.pointee = ObjCBool(isStopped) }
                        else {
                            totalProgress[asset] = progress
                            let progress = totalProgress.values.reduce(Double(), +) / Double(self.count)
                            stateCallback?(.progress(progress))
                        }
                    }
                })
            }
            Me.inMainQueue {
                if !isStopped { stateCallback?(.completed(self)) }
            }
        }
        return cancel
    }
}

fileprivate extension PHAsset {
    func _download(progressHandler: @escaping (Double, UnsafeMutablePointer<ObjCBool>) -> ()) {
        if mediaType == .video {
            let group = DispatchGroup()
            group.enter()
            Me.ImagesManager.shared.fetchVideo(with: self, progressHandler: progressHandler) { _ in group.leave() }
            group.wait()
        } else {
            Me.ImagesManager.shared.fetchImage(with: self, type: .original, isSynchronous: true, progressHandler: progressHandler) { _ in }
        }
    }
}
