//
//  ContentView.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit

public extension TanImagePicker {
    final class ContentView: UICollectionViewController {
        private let _customViewController: UIViewController?
        
        init(customViewController: UIViewController? = nil) {
            _customViewController = customViewController
            super.init(collectionViewLayout: _layout)
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let _layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = UI.imageMargin()
            layout.minimumInteritemSpacing = UI.imageMargin()
            layout.scrollDirection = UI.direction.collectionViewScrollDirection
            layout.sectionInset = {
                switch UI.direction {
                case .horizontal:
                    return UIEdgeInsets(top: UI.imageMargin(), left: 0, bottom: UI.imageMargin(), right: 0)
                case .vertical:
                    return UIEdgeInsets(top: 0, left: UI.imageMargin(), bottom: 0, right: UI.imageMargin())
                }
            }()
            return layout
        }()
        
        var needsLoadData: ((ContentView, UIView?) -> ())?
    }
}

extension TanImagePicker.ContentView {
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = Me.UI.backgroundColor
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        _setupCustomViewController()
        needsLoadData?(self, _customViewController?.view)
        if _customViewController != nil {
            _layout.headerReferenceSize = Me.UI.direction == .horizontal
                ? CGSize(width: Me.UI.customViewControllerWidthOrHeight(), height: 0)
                : CGSize(width: 0, height: Me.UI.customViewControllerWidthOrHeight())
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rowsOrColumnsCount = CGFloat(Me.UI.rowsOrColumnsCount())
        let referenceSizeValue = Me.UI.direction == .horizontal ? view.bounds.height : view.bounds.width
        let sizeValue = (referenceSizeValue - (rowsOrColumnsCount + 1) * Me.UI.imageMargin()) / rowsOrColumnsCount
        _layout.itemSize = CGSize(width: sizeValue, height: sizeValue)
    }
}

fileprivate extension TanImagePicker.ContentView {
    func _setupCustomViewController() {
        guard let customViewController = _customViewController else { return }
        addChildViewController(customViewController)
        customViewController.didMove(toParentViewController: self)
    }
}
