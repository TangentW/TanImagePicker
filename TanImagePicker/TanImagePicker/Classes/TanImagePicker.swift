//
//  TanImagePicker.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit
import Photos

public class TanImagePicker {
    public private(set) var selectedAssets: [PHAsset] = [] {
        didSet {
            _didSelectedAssets?(selectedAssets)
        }
    }
    public private(set) var shouldSendOriginalImages = false
    
    public let contentView: ContentView
    public let indicationView: SelectedImagesIndicationView
    
    private let _adapter = ImagesAdapter()
    private let _downloader = ImagesDownloader()
    private let _scrollingListener = ScrollingListener()
    private let _didSelectedAssets: (([PHAsset]) -> ())?
    
    public init(UI ui: Set<UIItem> = [],
                mediaOption: MediaOption,
                imagesLimit: Int = 0,
                selectedLimit: Int = 9,
                customViewController: UIViewController? = nil,
                didSelectedAssets: (([PHAsset]) -> ())? = nil) {
        UI.update(ui)
        contentView = ContentView(customViewController: customViewController)
        indicationView = SelectedImagesIndicationView()
        _didSelectedAssets = didSelectedAssets
        
        contentView.needsLoadData = { [weak self] in
            self?._adapter.setup(mediaOption: mediaOption, imagesLimit: imagesLimit,
                                selectedLimit: selectedLimit,
                                collectionView: $0, customView: $1)
            self?._adapter.load()
            self?._scrollingListener.listen()
        }
        
        indicationView.clearCallback = { [weak self] in
            self?._adapter.clearSelectedItems()
        }
        
        indicationView.deselectItemCallback = { [weak self] in
            self?._adapter.deselectItem($0)
        }
        
        indicationView.checkOriginalImagesCallback = { [weak self] in
            self?.shouldSendOriginalImages = $0
        }
        
        _adapter.didChangeSelectedItems = { [weak self] in
            self?.indicationView.provider.refresh($0)
            self?.selectedAssets = $0.map { $0.asset }
        }
        
        _scrollingListener.stateChanged = { [weak self] in
            self?._adapter.switchScrollingState(isScrolling: $0)
        }
    }
    
    public func finishPickingImages(stateCallback: DownloadingStateCallback<[PHAsset]>? = nil) {
        _downloader.download(selectedAssets, stateCallback: stateCallback)
    }
    
    public func cancelImagesDownloading() {
        _downloader.cancel()
    }
    
    public func clear() {
        _adapter.clearSelectedItems()
    }
    
    public func reloadAssets() {
        _adapter.load()
    }
    
    // File size
    public func calcSelectedAssetsSize(_ completionHandler: @escaping (Int) -> ()) {
        selectedAssets.calcSize(completionHandler: completionHandler)
    }
    
    public func calcSelectedAssetsSizeString(_ completionHandler: @escaping (String) -> ()) {
        calcSelectedAssetsSize { completionHandler($0.sizeString) }
    }
}

public extension TanImagePicker {
    struct MediaOption: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        // TODO: Support live photo
        public static let photo = MediaOption(rawValue: 1 << 0)
        public static let video = MediaOption(rawValue: 1 << 1)
        public static let all: MediaOption = [.photo, .video]
    }
    
    enum DownloadingState<T> {
        case progress(Double)
        case cancel
        case completed(T)
    }
    
    typealias DownloadingCancel = () -> ()
    typealias DownloadingStateCallback<T> = (DownloadingState<T>) -> ()
}

// MARK: - Queue
typealias Me = TanImagePicker
extension TanImagePicker {
    static let mainQueue = DispatchQueue.main
    static let asyncQueue = DispatchQueue(label: "TanImagePickerQueue")
}

extension TanImagePicker {
    static func inMainQueue(_ todo: @escaping () -> ()) {
        Me.mainQueue.async(execute: todo)
    }

    static func inAsyncQueue(_ todo: @escaping () -> ()) {
        Me.asyncQueue.async(execute: todo)
    }
}
