//
//  UI.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit

public extension TanImagePicker {
    public typealias Measure = () -> CGFloat
    enum UIItem {
        case contentViewbackgroundColor(UIColor)
        case imageMargin(Measure)
        case customViewControllerWidthOrHeight(Measure)
        case checkViewBottomMargin(Measure)
        case checkViewRightMargin(Measure)
        case videoOrLivePhotoMarkViewTopMargin(Measure)
        case videoOrLivePhotoMarkViewLeftMargin(Measure)
        case indicationViewImageMargin(Measure)
        case indicationViewBackgroundColor(UIColor)
        case indicationViewSendOriginalTitle(String)
        case cellProgressViewRadius(Measure)
        case cellProgressViewLineWidth(Measure)
        case automaticallyFetchVideoIfHas(Bool)
        case rowsOrColumnsCount(Measure)
        case direction(Direction)
        case enable3DTouchPreview(Bool)
        case enableLivePhoto(Bool)
    }
    
    enum Direction {
        case horizontal
        case vertical
        
        var collectionViewScrollDirection: UICollectionViewScrollDirection {
            switch self {
            case .horizontal: return .horizontal
            case .vertical: return .vertical
            }
        }
    }
}

extension TanImagePicker.UIItem: Hashable {
    public static func ==(lhs: TanImagePicker.UIItem, rhs: TanImagePicker.UIItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public var hashValue: Int {
        return "\(self)".split(separator: "(").first?.hashValue ?? 0
    }
}

extension TanImagePicker {
    struct UI {
        private(set) static var backgroundColor: UIColor = .white
        private(set) static var imageMargin: Measure = { 2 }
        private(set) static var customViewControllerWidthOrHeight: Measure = { 0.55 * UIScreen.main.bounds.width }
        private(set) static var checkViewBottomMargin: Measure = { 7 }
        private(set) static var checkViewHorizontalMargin: Measure = { 6 }
        private(set) static var indicationViewImageMargin: Measure = { 9 }
        private(set) static var indicationViewBackgroundColor: UIColor = .white
        private(set) static var indicationViewSendOriginalTitle = "Original".localizedString
        private(set) static var videoOrLivePhotoMarkViewTopMargin: Measure = { 10 }
        private(set) static var videoOrLivePhotoMarkVideLeftMargin: Measure = { 8 }
        private(set) static var cellProgressViewRadius: Measure = { 18 }
        private(set) static var cellProgressViewLineWidth: Measure = { 4 }
        private(set) static var automaticallyFetchVideosOrLivePhotosIfHas: Bool = true
        private(set) static var rowsOrColumnsCount: Measure = { 2 }
        private(set) static var direction: Direction = .horizontal
        private(set) static var enable3DTouchPreview: Bool = true
        private(set) static var enableLivePhoto: Bool = true
        
        private static func _update(_ item: UIItem) {
            switch item {
            case .contentViewbackgroundColor(let color):
                backgroundColor = color
            case .imageMargin(let margin):
                imageMargin = margin
            case .customViewControllerWidthOrHeight(let width):
                customViewControllerWidthOrHeight = width
            case .checkViewBottomMargin(let margin):
                checkViewBottomMargin = margin
            case .checkViewRightMargin(let margin):
                checkViewHorizontalMargin = margin
            case .indicationViewImageMargin(let margin):
                indicationViewImageMargin = margin
            case .indicationViewBackgroundColor(let color):
                indicationViewBackgroundColor = color
            case .indicationViewSendOriginalTitle(let title):
                indicationViewSendOriginalTitle = title
            case .videoOrLivePhotoMarkViewTopMargin(let margin):
                videoOrLivePhotoMarkViewTopMargin = margin
            case .videoOrLivePhotoMarkViewLeftMargin(let margin):
                videoOrLivePhotoMarkVideLeftMargin = margin
            case .cellProgressViewRadius(let radius):
                cellProgressViewRadius = radius
            case .cellProgressViewLineWidth(let width):
                cellProgressViewLineWidth = width
            case .automaticallyFetchVideoIfHas(let ok):
                automaticallyFetchVideosOrLivePhotosIfHas = ok
            case .rowsOrColumnsCount(let count):
                rowsOrColumnsCount = count
            case .direction(let dir):
                direction = dir
            case .enable3DTouchPreview(let enable):
                enable3DTouchPreview = enable
            case .enableLivePhoto(let enable):
                enableLivePhoto = enable
            }
        }
        
        static func update(_ items: Set<UIItem>) {
            items.forEach(_update)
        }
    }
}
