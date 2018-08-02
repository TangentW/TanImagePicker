//
//  ImageCell.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

private var _livePhotoPlayerKey: UInt8 = 23
private let _magicMarginNumber: CGFloat = 6
extension TanImagePicker {
    final class ImageCell: UICollectionViewCell, ReusableView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UI.backgroundColor
            contentView.addSubview(_imageView)
            contentView.addSubview(_playerView)
            if #available(iOS 9.1, *) {
                contentView.addSubview(_livePhotoPlayer)
            }
            contentView.addSubview(_progressView)
            contentView.addSubview(_checkView)
            contentView.addSubview(_videoMarkView)
            contentView.addSubview(_videoDurationView)
            contentView.addSubview(_livePhotoMarkView)
        }
        
        deinit {
            _clear()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _imageView: UIImageView = {
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return $0
        }(UIImageView())
        
        private let _checkView: _CheckView = {
            $0.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            $0.isHidden = true
            return $0
        }(_CheckView())
        
        private let _videoMarkView: UIImageView = {
            $0.sizeToFit()
            $0.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            $0.isHidden = true
            return $0
        }(UIImageView(image: UIImage(named: "video", in: Bundle.myBundle, compatibleWith: nil)))
        
        private let _videoDurationView: UILabel = {
            let label = UILabel()
            label.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            label.textColor = .white
            label.font = .systemFont(ofSize: 13)
            label.isHidden = true
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOffset = .zero
            label.layer.shadowRadius = 1
            label.layer.shadowOpacity = 0.5
            return label
        }()
        
        private let _livePhotoMarkView: UIImageView = {
            $0.sizeToFit()
            $0.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            $0.isHidden = true
            return $0
        }(UIImageView(image: UIImage(named: "livephoto", in: Bundle.myBundle, compatibleWith: nil)))
        
        private let _playerView: _PlayeView = {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.isHidden = true
            return $0
        }(_PlayeView())
        
        @available(iOS 9.1, *)
        private var _livePhotoPlayer: _LivePhotoPlayer {
            return (objc_getAssociatedObject(self, &_livePhotoPlayerKey) as? _LivePhotoPlayer)
                ?? {
                    let result = _LivePhotoPlayer()
                    objc_setAssociatedObject(self, &_livePhotoPlayerKey, result, .OBJC_ASSOCIATION_RETAIN)
                    return result
                }()
        }
        
        private let _progressView: _ProgressView = {
            $0.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            $0.isHidden = true
            return $0
        }(_ProgressView())
        
        // For Image
        private var _imageRequestID: PHImageRequestID?
        // For Video Or Live Photo
        private var _videoOrLivePhotoRequestID: PHImageRequestID?
        private var _isScrolling = true
        
        var isContentViewCell: Bool = true
        
        var item: ImageItem? {
            didSet {
                guard let item = item else { return }
                _beginFetchImage(item)
                _beginFetchVideoOrLivePhoto(item)
                _bindItem(item)
            }
        }
    }
}

extension TanImagePicker.ImageCell {
    private var _normalCheckViewX: CGFloat {
        return bounds.width - Me.UI.checkViewHorizontalMargin() - _checkView.bounds.width
    }
    
    private var _normalCheckViewY: CGFloat {
        return bounds.height - Me.UI.checkViewBottomMargin() - _checkView.bounds.height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _imageView.frame = bounds
        _checkView.frame.origin.x = _normalCheckViewX
        _checkView.frame.origin.y = _normalCheckViewY
        [_videoMarkView, _livePhotoMarkView].forEach {
            $0.frame.origin.x = Me.UI.videoOrLivePhotoMarkVideLeftMargin()
            $0.frame.origin.y = Me.UI.videoOrLivePhotoMarkViewTopMargin()
        }
        _videoDurationView.center.y = _videoMarkView.center.y
        _videoDurationView.frame.origin.x = _videoMarkView.frame.maxX + Me.UI.videoOrLivePhotoMarkVideLeftMargin()
        _playerView.frame = bounds
        _progressView.center = _playerView.center
        if #available(iOS 9.1, *) {
            _livePhotoPlayer.frame = bounds
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _checkView.frame.origin.x = Me.UI.direction == .horizontal ? _magicMarginNumber : _normalCheckViewX
        _checkView.frame.origin.y = Me.UI.direction == .vertical ? _magicMarginNumber : _normalCheckViewY
        _clear()
    }
}

private extension TanImagePicker.ImageCell {
    func _unbindItem(_ item: Me.ImageItem) {
        guard isContentViewCell, item.bindedCell === self else { return }
        item.selectedStateCallback = nil
        item.canSelectedCallback = nil
    }
    
    func _bindItem(_ item: Me.ImageItem) {
        guard isContentViewCell else { return }
        _checkView.refresh(isSelected: item.isSelected)
        _checkView.isHidden = !item.canSelected
        
        _videoMarkView.isHidden = item.assetType != .video
        _videoDurationView.isHidden = item.assetType != .video
        _videoDurationView.text = item.asset.duration.formatString
        _videoDurationView.sizeToFit()
        
        _livePhotoMarkView.isHidden = item.assetType != .livePhoto
        _progressView.isHidden = item.assetType == .normal
        
        item.selectedStateCallback = { [weak self] in
            self?._checkView.refresh(isSelected: $0)
        }
        item.canSelectedCallback = { [weak self] in
            self?._checkView.isHidden = !$0
        }
        item.bindedCell = self
    }
    
    func _beginFetchVideoOrLivePhoto(_ item: Me.ImageItem) {
        guard item.assetType == .video || item.assetType == .livePhoto, Me.UI.automaticallyFetchVideosOrLivePhotosIfHas else { return }
        if item.assetType == .video {
            _videoOrLivePhotoRequestID = Me.ImagesManager.shared.fetchVideo(with: item.asset, progressHandler: { [weak self] progress, _ in
                Me.inMainQueue {
                    self?._progressView.progress = progress
                }
            }, completionHandler: { [weak self] video in
                    Me.inMainQueue {
                        self?._progressView.isHidden = true
                        self?._playerView.isHidden = false
                        self?._playerView.video = video
                        if self?.isContentViewCell == false || self?._isScrolling == false {
                            self?._playerView.play()
                        }
                    }
            })
        }
        else if #available(iOS 9.1, *), item.assetType == .livePhoto {
            _videoOrLivePhotoRequestID = Me.ImagesManager.shared.fetchLivePhoto(with: item.asset, progressHandler: { [weak self] progress, _ in
                Me.inMainQueue {
                    self?._progressView.progress = progress
                }
            }, completionHandler: { [weak self] livePhoto in
                    Me.inMainQueue {
                        self?._progressView.isHidden = true
                        self?._livePhotoPlayer.isHidden = false
                        self?._livePhotoPlayer.livePhoto = livePhoto
                        if self?.isContentViewCell == false || self?._isScrolling == false {
                            self?._livePhotoPlayer.play()
                        }
                    }
            })
        }
    }
    
    func _cancelVideoOrLivePhotoFetching() {
        _playerView.isHidden = true
        if #available(iOS 9.1, *) { _livePhotoPlayer.isHidden = true }
        if let videoRequestID = _videoOrLivePhotoRequestID {
            PHImageManager.default().cancelImageRequest(videoRequestID)
        }
        _playerView.clear()
        if #available(iOS 9.1, *) { _livePhotoPlayer.livePhoto = nil }
    }
    
    func _beginFetchImage(_ item: Me.ImageItem) {
        _imageRequestID = Me.ImagesManager.shared.fetchImage(with: item.asset, type: .thumbnail(size: bounds.size)) { [weak self] in
            self?._imageView.image = $0
        }
    }
    
    func _cancalImageFecthing() {
        if let imageRequestID = _imageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        _imageView.image = nil
    }
    
    func _clear() {
        if let oldItem = item { _unbindItem(oldItem) }
        _cancalImageFecthing()
        _cancelVideoOrLivePhotoFetching()
    }
}

// Listen ContentView Scrolling
extension TanImagePicker.ImageCell {
    private func _layoutCheckViewWithMaxX(_ x: CGFloat) {
        _checkView.frame.origin.x = x - Me.UI.checkViewHorizontalMargin() - _checkView.bounds.width
    }

    private func _layoutCheckViewWithMaxY(_ y: CGFloat) {
        _checkView.frame.origin.y = y - Me.UI.checkViewBottomMargin() - _checkView.bounds.height
    }
    
    func scrolling(collectionView: UICollectionView) {
        guard let superview = superview else { return }
        let cellFrame = collectionView.convert(frame, from: superview)

        switch Me.UI.direction {
        case .horizontal:
            let maxX = min(cellFrame.maxX, collectionView.bounds.maxX) - cellFrame.origin.x
            guard maxX > Me.UI.checkViewHorizontalMargin() + _checkView.bounds.width + _magicMarginNumber else { return }
            _layoutCheckViewWithMaxX(maxX)
        case .vertical:
            let maxY = min(cellFrame.maxY, collectionView.bounds.maxY) - cellFrame.origin.y
            guard maxY > Me.UI.checkViewBottomMargin() + _checkView.bounds.height + _magicMarginNumber else { return }
            _layoutCheckViewWithMaxY(maxY)
        }
    }
    
    func switchScrollingState(isScrolling: Bool) {
        guard isContentViewCell else { return }
        _isScrolling = isScrolling
        if isScrolling {
            _playerView.pause()
            if #available(iOS 9.1, *) {
                _livePhotoPlayer.stop()
            }
        } else {
            _playerView.play()
            if #available(iOS 9.1, *) {
                _livePhotoPlayer.play()
            }
        }
    }
}

// MARK: - CheckView
private let imageMark = UIImage(named: "image_mark", in: Bundle.myBundle, compatibleWith: nil)
private let imageMarkSel = UIImage(named: "image_mark_sel", in: Bundle.myBundle, compatibleWith: nil)
private extension TanImagePicker.ImageCell {
    final class _CheckView: UIImageView {
        init() {
            super.init(image: imageMark)
            setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func refresh(isSelected: Bool) {
            image = isSelected ? imageMarkSel : imageMark
        }
    }
}

// MARK: - PlayerView
private extension TanImagePicker.ImageCell {
    final class _PlayeView: UIView {
        private lazy var _player: AVPlayer = {
            let player = AVPlayer()
            player.isMuted = true
            return player
        }()
        
        private lazy var _playerLayer: AVPlayerLayer = {
            let layer = AVPlayerLayer(player: $0)
            layer.videoGravity = .resizeAspectFill
            return layer
        }(_player)
        
        init() {
            super.init(frame: .zero)
            layer.addSublayer(_playerLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            _playerLayer.frame = bounds
        }
        
        var video: AVAsset?
    }
}

extension TanImagePicker.ImageCell._PlayeView {
    func play() {
        if _player.currentItem != nil {
            _player.play()
        } else if let mVideo = video {
            mVideo.loadValuesAsynchronously(forKeys: ["playable"], completionHandler: { [weak self] in
                let item = AVPlayerItem(asset: mVideo)
                self?._player.replaceCurrentItem(with: item)
                self?._loopToPlay(item: item)
                self?._player.play()
            })
        }
    }
    
    func pause() {
        _player.pause()
    }
    
    var isPause: Bool {
        return _player.rate == 0
    }
    
    func clear() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        _player.replaceCurrentItem(with: nil)
        video = nil
    }
}

private extension TanImagePicker.ImageCell._PlayeView {
    func _loopToPlay(item: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(TanImagePicker.ImageCell._PlayeView._playBack), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    @objc func _playBack() {
        _player.seek(to: kCMTimeZero)
        play()
    }
}

// MARK: - LivePhotoPlayer
@available(iOS 9.1, *)
private extension TanImagePicker {
    final class _LivePhotoPlayer: PHLivePhotoView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            isMuted = true
            isUserInteractionEnabled = !Me.UI.enable3DTouchPreview
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func play() {
            guard livePhoto != nil else { return }
            startPlayback(with: .hint)
        }
        
        func stop() {
            stopPlayback()
        }
    }
}

// MARK: - ProgressView
private let progressViewSize = CGSize(width: 2 * Me.UI.cellProgressViewRadius(), height: 2 * Me.UI.cellProgressViewRadius())
private extension TanImagePicker.ImageCell {
    final class _ProgressView: UIView {
        var progress: Double = 0 {
            didSet {
                _shapeLayer.strokeEnd = min(1, max(0, CGFloat(progress)))
            }
        }
        
        init() {
            super.init(frame: CGRect(origin: .zero, size: progressViewSize))
            layer.addSublayer(_shapeLayer)
            _shapeLayer.path = _path
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 1.8
            layer.shadowOpacity = 0.2
            layer.shadowOffset = CGSize(width: 1, height: 1)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _path: CGPath = {
            let center = CGPoint(x: 0.5 * progressViewSize.width, y: 0.5 * progressViewSize.height)
            return UIBezierPath(arcCenter: center, radius: Me.UI.cellProgressViewRadius(), startAngle: -0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true).cgPath
        }()
        
        private let _shapeLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.lineCap = kCALineCapRound
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = UIColor.white.cgColor
            layer.strokeStart = 0
            layer.strokeEnd = 0
            layer.zPosition = 1
            layer.lineWidth = Me.UI.cellProgressViewLineWidth()
            return layer
        }()
        
        override func layoutSubviews() {
            super.layoutSubviews()
            _shapeLayer.frame = bounds
        }
    }
}
