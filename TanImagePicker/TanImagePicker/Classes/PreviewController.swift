//
//  PreviewController.swift
//  TanImagePicker
//
//  Created by Tangent on 01/02/2018.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

extension TanImagePicker {
    final class PreviewController: UIViewController {
        private let _item: ImageItem
        private var _requestID: PHImageRequestID?
        private var _videoRequestID: PHImageRequestID?
        
        init(item: ImageItem) {
            _item = item
            super.init(nibName: nil, bundle: nil)
            preferredContentSize = _fetchSize()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            if let requestID = _requestID {
                PHImageManager.default().cancelImageRequest(requestID)
            }
            if let videoRequestID = _videoRequestID {
                PHImageManager.default().cancelImageRequest(videoRequestID)
            }
        }
        
        private lazy var _tipLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 22)
            label.text = "Fetching".localizedString
            return label
        }()
        
        private lazy var _blurView: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .dark)
            let view = UIVisualEffectView(effect: effect)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return view
        }()
        
        private lazy var _imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        private var _playerView: _PlayerView?
        private var _livePhotoPlayer: UIView?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
            view.addSubview(_blurView)
            view.addSubview(_imageView)
            _blurView.contentView.addSubview(_tipLabel)
            _tipLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                _tipLabel.centerXAnchor.constraint(equalTo: _blurView.contentView.centerXAnchor),
                _tipLabel.centerYAnchor.constraint(equalTo: _blurView.contentView.centerYAnchor)
            ])
            
            _requestID = ImagesManager.shared.fetchImage(with: _item.asset, type: Me.ImagesManager.ImageFetchType.original, isSynchronous: false) { [weak self] image in
                Me.inMainQueue {
                    self?._tipLabel.isHidden = true
                    self?._imageView.image = image
                }
            }
            
            if _item.assetType == .video {
                let asset = _item.asset
                ImagesManager.shared.fetchVideo(with: asset, progressHandler: nil) { [weak self] video in
                    Me.inMainQueue {
                        let playerView = _PlayerView(video: video)
                        self?._playerView = playerView
                        self?.view.addSubview(playerView)
                    }
                }
            }
            else if #available(iOS 9.1, *), _item.assetType == .livePhoto {
                let asset = _item.asset
                ImagesManager.shared.fetchLivePhoto(with: asset, completionHandler: { [weak self] in
                    guard let livePhoto = $0 else { return }
                    Me.inMainQueue {
                        let player = _LivePhotoPlayer(livePhoto: livePhoto)
                        self?._livePhotoPlayer = player
                        self?.view.addSubview(player)
                        player.play()
                    }
                })
            }
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            _blurView.frame = view.bounds
            _imageView.frame = view.bounds
            _playerView?.frame = view.bounds
            _livePhotoPlayer?.frame = view.bounds
        }
        
        private func _fetchSize() -> CGSize {
            let ratio = CGFloat(_item.asset.pixelHeight) / CGFloat(_item.asset.pixelWidth)
            var width = UIScreen.main.bounds.width
            let height = min(ratio * width, UIScreen.main.bounds.height)
            width = min(height / ratio, UIScreen.main.bounds.width)
            return CGSize(width: width, height: height)
        }
    }
}

private extension TanImagePicker.PreviewController {
    final class _PlayerView: UIView {
        private lazy var _player: AVPlayer = {
            let player = AVPlayer()
            player.isMuted = false
            return player
        }()
        
        private lazy var _playerLayer: AVPlayerLayer = {
            let layer = AVPlayerLayer(player: $0)
            layer.videoGravity = .resizeAspectFill
            return layer
        }(_player)
        
        private let _video: AVAsset
        private var _loopToPlayObserver: NSObjectProtocol?
        
        init(video: AVAsset) {
            _video = video
            super.init(frame: .zero)
            layer.addSublayer(_playerLayer)
            _play()
        }
        
        deinit {
            if let loopToPlayObserver = _loopToPlayObserver {
                NotificationCenter.default.removeObserver(loopToPlayObserver)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            _playerLayer.frame = layer.bounds
        }
        
        private func _play() {
            if _player.currentItem != nil {
                _player.play()
            } else {
                let video = _video
                video.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
                    let item = AVPlayerItem(asset: video)
                    self?._player.replaceCurrentItem(with: item)
                    self?._loopToPlay(item: item)
                    self?._player.play()
                }
            }
        }
        
        private func _loopToPlay(item: AVPlayerItem) {
            _loopToPlayObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
                self?._player.seek(to: kCMTimeZero)
                self?._play()
            }
        }
    }
    
    @available(iOS 9.1, *)
    final class _LivePhotoPlayer: PHLivePhotoView, PHLivePhotoViewDelegate {
        init(livePhoto: PHLivePhoto) {
            super.init(frame: .zero)
            self.livePhoto = livePhoto
            delegate = self
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func play() {
            startPlayback(with: .full)
        }
        
        func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
            startPlayback(with: .full)
        }
    }
}
