//
//  ImagesAdapter.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit

extension TanImagePicker {
    final class ImagesAdapter: NSObject {
        private var _items: [ImageItem] = []
        private var _scrollingListeners: Set<ImageCell> = []
        private var _selectedLimit: Int = 0
        
        private weak var _collectionView: UICollectionView?
        private weak var _customView: UIView?
        
        private var _selectedItems: [ImageItem] = []
        var didChangeSelectedItems: (([ImageItem]) -> ())?
    }
}

extension TanImagePicker.ImagesAdapter {
    func load(mediaOption: Me.MediaOption, imagesLimit: Int, selectedLimit: Int, collectionView: UICollectionView, customView: UIView?) {
        _collectionView = collectionView
        _customView = customView
        _selectedLimit = selectedLimit
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(Me.ImageCell.self, forCellWithReuseIdentifier: Me.ImageCell.identifier)
        collectionView.register(Me.CustomViewContainer.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Me.CustomViewContainer.identifier)
        
        _scrollingListeners.removeAll(keepingCapacity: true)
        
        Me.inAsyncQueue {
            let items = Me.ImagesManager.shared.fetchRecentAssets(mediaOption: mediaOption, limit: imagesLimit).map(Me.ImageItem.init)
            if selectedLimit == 0 { items.forEach { $0.canSelected = false } }
            Me.inMainQueue {
                self._items = items
                collectionView.reloadData()
                // For layout ImageCell's mark view.
                Me.inMainQueue { self.scrollViewDidScroll(collectionView) }
            }
        }
    }
    
    func switchScrollingState(isScrolling: Bool) {
        _scrollingListeners.forEach { $0.switchScrollingState(isScrolling: isScrolling) }
    }
    
    func selectedItem(_ item: Me.ImageItem) {
        guard item.canSelected else { return }
        item.isSelected = true
        if !_selectedItems.contains(item) { _selectedItems.append(item) }
        if _selectedItems.count >= _selectedLimit {
            _items.forEach {
                $0.canSelected = false
            }
            _selectedItems.forEach {
                $0.canSelected = true
            }
        }
        didChangeSelectedItems?(_selectedItems)
    }
    
    func deselectItem(_ item: Me.ImageItem) {
        guard item.canSelected else { return }
        item.isSelected = false
        if let index = _selectedItems.index(of: item) {
            _selectedItems.remove(at: index)
        }
        if _selectedItems.count == _selectedLimit - 1 {
            _items.forEach { $0.canSelected = true }
        }
        didChangeSelectedItems?(_selectedItems)
    }
    
    func clearSelectedItems() {
        _selectedItems.forEach { $0.isSelected = false }
        _selectedItems.removeAll(keepingCapacity: false)
        if _selectedLimit != 0 { _items.forEach { $0.canSelected = true } }
        didChangeSelectedItems?(_selectedItems)
    }
}

extension TanImagePicker.ImagesAdapter: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Me.ImageCell.identifier, for: indexPath) as! Me.ImageCell
        _scrollingListeners.insert(cell)
        cell.item = _items[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let container = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Me.CustomViewContainer.identifier, for: indexPath) as! Me.CustomViewContainer
        if container.customView == nil { container.customView = _customView }
        return container
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = _items[indexPath.item]
        if !item.isSelected { selectedItem(item) }
        else { deselectItem(item) }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = _collectionView else { return }
        _scrollingListeners.forEach { $0.scrolling(collectionView: collectionView) }
    }
}

extension TanImagePicker {
    final class CustomViewContainer: UICollectionReusableView, ReusableView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UI.backgroundColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var customView: UIView? {
            didSet {
                customView?.removeFromSuperview()
                if let customView = customView { addSubview(customView) }
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            customView?.frame = bounds
        }
    }
}
