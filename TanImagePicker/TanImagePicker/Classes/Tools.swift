//
//  Tools.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit

extension UIImage {
    func scaleTo(size: CGSize) -> UIImage? {
        if self.size.width > size.width {
            UIGraphicsBeginImageContext(size)
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let retImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return retImage
        } else {
            return self
        }
    }
}

protocol ReusableView { }
extension ReusableView {
    static var identifier: String {
        return String(describing: self)
    }
}
