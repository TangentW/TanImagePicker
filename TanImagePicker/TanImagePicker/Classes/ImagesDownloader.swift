//
//  ImagesDownloader.swift
//  TanImagePicker
//
//  Created by Tangent on 20/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import Foundation
import Photos

public extension TanImagePicker {
    final class ImagesDownloader {
        public typealias Cancel = () -> ()
        public typealias StateCallback = (State) -> ()
        
        private var _cancel: Cancel?
        
        public func download(_ assets: [PHAsset], stateCallback: StateCallback?) {
            _cancel = assets._downloadAssets(stateCallback: stateCallback)
        }
        
        public func cancel() {
            _cancel?()
        }
        
        deinit { _cancel?() }
    }
}

public extension TanImagePicker.ImagesDownloader {
    enum State {
        case progress(Double)
        case cancel
        case completed
    }
}

fileprivate extension Array where Element == PHAsset {
    func _downloadAssets(stateCallback: Me.ImagesDownloader.StateCallback?) -> Me.ImagesDownloader.Cancel {
        assert(Thread.isMainThread, "This method must be called in main thread.")
        var isStopped = false
        let cancel = { isStopped = true; stateCallback?(.cancel) }
        var totalProgress: [PHAsset: Double] = [:]
        
        Me.asyncQueue.async {
            self.forEach { asset in
                asset._download(progressHandler: { progress, stop in
                    Me.mainQueue.async {
                        if isStopped { stop.pointee = ObjCBool(isStopped) }
                        else {
                            totalProgress[asset] = progress
                            let progress = totalProgress.values.reduce(Double(), +) / Double(self.count)
                            stateCallback?(.progress(progress))
                        }
                    }
                })
            }
            Me.mainQueue.async {
                if !isStopped { stateCallback?(.completed) }
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
