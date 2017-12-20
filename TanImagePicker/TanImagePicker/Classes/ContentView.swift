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
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: UI.imageMargin(), left: 0, bottom: UI.imageMargin(), right: 0)
            return layout
        }()
        
        var needsLoadData: ((UICollectionView, UIView?) -> ())?
    }
}

extension TanImagePicker.ContentView {
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = Me.UI.backgroundColor
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        _setupCustomViewController()
        if let cv = collectionView { needsLoadData?(cv, _customViewController?.view) }
        if _customViewController != nil {
            _layout.headerReferenceSize = CGSize(width: Me.UI.customViewControllerWidth(), height: 0)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sizeValue = 0.5 * (view.bounds.height - 3 * Me.UI.imageMargin())
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
