//
//  SelectedImagesIndicationView.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit

public extension TanImagePicker {
    final class SelectedImagesIndicationView: UIViewController {
        
        let provider = SelectedItemsProvider()
        
        private lazy var  _layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = UI.indicationViewImageMargin()
            layout.minimumInteritemSpacing = UI.indicationViewImageMargin()
            return layout
        }()
        
        private lazy var _collectionView: UICollectionView = {
            $0.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = UI.indicationViewBackgroundColor
            return $0
        }(UICollectionView(frame: view.bounds, collectionViewLayout: _layout))
        
        private lazy var _clearButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(named: "clear")?.withRenderingMode(.alwaysOriginal), for: .normal)
            button.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
            return button
        }()
        
        private lazy var _originalImagesCheckbox: UIButton = {
            let button = UIButton()
            button.setTitle("Original".localizedString, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13)
            button.setTitleColor(.darkGray, for: .normal)
            button.setImage(UIImage(named: "check_box")?.withRenderingMode(.alwaysOriginal), for: .normal)
            button.setImage(UIImage(named: "check_box_light")?.withRenderingMode(.alwaysOriginal), for: .selected)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
            return button
        }()
        
        var clearCallback: (() -> ())?
        var checkOriginalImagesCallback: ((Bool) -> ())?
        var deselectItemCallback: ((ImageItem) -> ())?
    }
}

extension TanImagePicker.SelectedImagesIndicationView {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Me.UI.indicationViewBackgroundColor
        view.addSubview(_collectionView)
        view.addSubview(_clearButton)
        view.addSubview(_originalImagesCheckbox)
        _clearButton.addTarget(self, action: #selector(Me.SelectedImagesIndicationView._clearBtnClick), for: .touchUpInside)
        _originalImagesCheckbox.addTarget(self, action: #selector(Me.SelectedImagesIndicationView._originalImagesBtnClick), for: .touchUpInside)
        provider.bind(collectionView: _collectionView) { [weak self] in
            self?.deselectItemCallback?($0)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let clearButtonSizeValue = view.bounds.height
        _clearButton.frame.size = CGSize(width: clearButtonSizeValue, height: clearButtonSizeValue)
        let itemSizeValue = view.bounds.height - 2 * Me.UI.indicationViewImageMargin()
        _layout.itemSize = CGSize(width: itemSizeValue, height: itemSizeValue)
        let originalImagesCheckboxWidth = 2 * itemSizeValue
        _originalImagesCheckbox.frame = CGRect(x: view.bounds.width - originalImagesCheckboxWidth, y: 0, width: originalImagesCheckboxWidth, height: view.bounds.height)
        _collectionView.frame = CGRect(x: view.bounds.height, y: 0, width: view.bounds.width - view.bounds.height - originalImagesCheckboxWidth, height: view.bounds.height)
    }
    
    @objc private func _clearBtnClick() {
        clearCallback?()
    }
    
    @objc private func _originalImagesBtnClick() {
        _originalImagesCheckbox.isSelected = !_originalImagesCheckbox.isSelected
        checkOriginalImagesCallback?(_originalImagesCheckbox.isSelected)
    }
}

extension TanImagePicker.SelectedImagesIndicationView {
    final class SelectedItemsProvider: NSObject {
        private weak var _collectionView: UICollectionView?
        private var _selectedCallback: ((Me.ImageItem) -> ())?
        
        private var _selectedItems: [Me.ImageItem] = []
        
        func refresh(_ selectedItems: [Me.ImageItem]) {
            _selectedItems = selectedItems
            _collectionView?.reloadData()
            Me.mainQueue.async {
                guard self._selectedItems.count > 0 else { return }
                self._collectionView?.scrollToItem(at: IndexPath(item: self._selectedItems.count - 1, section: 0), at: .right, animated: true)
            }
        }
        
        func bind(collectionView: UICollectionView, selectedCallback: @escaping (Me.ImageItem) -> ()) {
            _collectionView = collectionView
            _selectedCallback = selectedCallback
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(Me.ImageCell.self, forCellWithReuseIdentifier: String(describing: Me.ImageCell.self))
        }
    }
}

extension TanImagePicker.SelectedImagesIndicationView.SelectedItemsProvider: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _selectedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Me.ImageCell.identifier, for: indexPath) as! Me.ImageCell
        cell.isContentViewCell = false
        cell.item = _selectedItems[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = _selectedItems[indexPath.item]
        _selectedCallback?(item)
    }
}
