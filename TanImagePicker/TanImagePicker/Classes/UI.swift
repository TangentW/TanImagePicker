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
        case customViewControllerWidth(Measure)
        case markViewBottomMargin(Measure)
        case markViewRightMargin(Measure)
        case indicationViewImageMargin(Measure)
        case indicationViewBackgroundColor(UIColor)
    }
}

extension TanImagePicker.UIItem: Hashable {
    public static func ==(lhs: TanImagePicker.UIItem, rhs: TanImagePicker.UIItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public var hashValue: Int {
        switch self {
        case .contentViewbackgroundColor: return 0
        case .imageMargin: return 1
        case .customViewControllerWidth: return 2
        case .markViewBottomMargin: return 3
        case .markViewRightMargin: return 4
        case .indicationViewImageMargin: return 5
        case .indicationViewBackgroundColor: return 6
        }
    }
}

public extension TanImagePicker {
    struct UI {
        private(set) static var backgroundColor: UIColor = .white
        private(set) static var imageMargin: Measure = { 2 }
        private(set) static var customViewControllerWidth: Measure = { 0.55 * UIScreen.main.bounds.width }
        private(set) static var markViewBottomMargin: Measure = { 7 }
        private(set) static var markViewHorizontalMargin: Measure = { 6 }
        private(set) static var indicationViewImageMargin: Measure = { 9 }
        private(set) static var indicationViewBackgroundColor: UIColor = .white
        
        private static func _update(_ item: UIItem) {
            switch item {
            case .contentViewbackgroundColor(let color):
                backgroundColor = color
            case .imageMargin(let margin):
                imageMargin = margin
            case .customViewControllerWidth(let width):
                customViewControllerWidth = width
            case .markViewBottomMargin(let margin):
                markViewBottomMargin = margin
            case .markViewRightMargin(let margin):
                markViewHorizontalMargin = margin
            case .indicationViewImageMargin(let margin):
                indicationViewImageMargin = margin
            case .indicationViewBackgroundColor(let color):
                indicationViewBackgroundColor = color
            }
        }
        
        static func update(_ items: Set<UIItem>) {
            items.forEach(_update)
        }
    }
}
