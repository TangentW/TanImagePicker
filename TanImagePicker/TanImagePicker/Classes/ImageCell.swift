//
//  ImageCell.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit
import Photos

extension TanImagePicker {
    final class ImageCell: UICollectionViewCell, ReusableView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UI.backgroundColor
            contentView.addSubview(_imageView)
            contentView.addSubview(_markView)
        }
        
        deinit {
            _cancalImageFecthing()
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
        
        private let _markView: _MarkView = {
            $0.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            $0.isHidden = true
            return $0
        }(_MarkView())
        
        // For Image
        private var _imageRequestID: PHImageRequestID?
        
        var shouldBindItemStatus: Bool = true
        
        var item: ImageItem? {
            didSet {
                if let oldItem = oldValue { _unbindItem(oldItem) }
                guard let item = item else { return }
                _beginFetchImage(item)
                _bindItem(item)
            }
        }
    }
}

extension TanImagePicker.ImageCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        _imageView.frame = bounds
        _markView.frame.origin.x = bounds.width - Me.UI.markViewHorizontalMargin() - _markView.bounds.width
        _markView.frame.origin.y = bounds.height - Me.UI.markViewBottomMargin() - _markView.bounds.height
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _cancalImageFecthing()
    }
}

private extension TanImagePicker.ImageCell {
    func _displayImageView(isSelected: Bool, animated: Bool) {
        let scale: CGFloat = 0.8
        let tran: CGAffineTransform = isSelected ? .init(scaleX: scale, y: scale) : .identity
        if animated {
            UIView.animate(withDuration: 0.2) { self._imageView.transform = tran }
        } else {
            _imageView.transform = tran
        }
    }
    
    func _unbindItem(_ item: Me.ImageItem) {
        guard shouldBindItemStatus, item.bindedCell === self else { return }
        item.selectedStateCallback = nil
        item.canSelectedCallback = nil
    }
    
    func _bindItem(_ item: Me.ImageItem) {
        guard shouldBindItemStatus else { return }
        _markView.refresh(isSelected: item.isSelected)
        _markView.isHidden = !item.canSelected
        _displayImageView(isSelected: item.isSelected, animated: false)
        item.selectedStateCallback = { [weak self] in
            self?._markView.refresh(isSelected: $0)
            self?._displayImageView(isSelected: $0, animated: true)
        }
        item.canSelectedCallback = { [weak self] in
            self?._markView.isHidden = !$0
        }
        item.bindedCell = self
    }
    
    func _beginFetchImage(_ item: Me.ImageItem) {
        _imageRequestID = Me.ImagesManager.shared.fetchImage(with: item.asset, type: .thumbnail(size: bounds.size)) { [weak self] in
            self?._imageView.image = $0
        }
    }
    
    func _cancalImageFecthing() {
        _imageView.image = nil
        if let imageRequestID = _imageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
    }
}

// Listen ContentView Scrolling
extension TanImagePicker.ImageCell {
    private func _layoutMarkViewWithMaxX(_ x: CGFloat) {
        _markView.frame.origin.x = x - Me.UI.markViewHorizontalMargin() - _markView.bounds.width
    }
    
    func scrolling(collectionView: UICollectionView) {
        guard let superview = superview else { return }
        let cellFrame = collectionView.convert(frame, from: superview)
        let maxX = min(cellFrame.maxX, collectionView.bounds.maxX) - cellFrame.origin.x
        let magicMarginNumber: CGFloat = 6
        guard maxX > Me.UI.markViewHorizontalMargin() + _markView.bounds.width + magicMarginNumber else { return }
        _layoutMarkViewWithMaxX(maxX)
    }
}

// MARK: - MarkView
private let imageMark = UIImage(named: "image_mark")
private let imageMarkSel = UIImage(named: "image_mark_sel")
private extension TanImagePicker.ImageCell {
    final class _MarkView: UIImageView {
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
            player.volume = 0
            return player
        }()
        
        private lazy var _playerLayer: AVPlayerLayer = {
            let layer = AVPlayerLayer(player: $0)
            layer.videoGravity = .resizeAspectFill
            return layer
        }(_player)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.addSublayer(_playerLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            _playerLayer.frame = bounds
        }
    }
}

extension TanImagePicker.ImageCell._PlayeView {
    func play(_ asset: AVAsset) {
        _player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        _player.play()
    }
    
    func pause() {
        _player.pause()
    }
}
