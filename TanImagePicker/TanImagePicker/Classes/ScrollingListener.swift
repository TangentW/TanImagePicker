//
//  ScrollingListener.swift
//  TanImagePicker
//
//  Created by Tangent on 20/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import Foundation

extension TanImagePicker {
    final class ScrollingListener {
        private var _runloopObserver: CFRunLoopObserver?
        
        private(set) var isScrolling = false {
            didSet {
                stateChanged?(isScrolling)
            }
        }
        
        func listen() {
            let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, (CFRunLoopActivity.entry.rawValue | CFRunLoopActivity.exit.rawValue), true, 0) { [weak self] _, activity in
                switch activity {
                case .entry:
                    self?.isScrolling = false
                case .exit:
                    self?.isScrolling = true
                default: ()
                }
            }
            CFRunLoopAddObserver(CFRunLoopGetMain(), observer, .defaultMode)
            _runloopObserver = observer
        }
        
        deinit {
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), _runloopObserver, .defaultMode)
        }
        
        // isScrolling
        var stateChanged: ((Bool) -> ())?
    }
}
