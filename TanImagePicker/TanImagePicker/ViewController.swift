//
//  ViewController.swift
//  TanImagePicker
//
//  Created by Tangent on 19/12/2017.
//  Copyright © 2017 Tangent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var _picker = TanImagePicker(mediaOption: .all, customViewController: TestViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        let pickerContentView = _picker.contentView
        addChildViewController(pickerContentView)
        view.addSubview(pickerContentView.view)
        pickerContentView.view.frame = CGRect(x: 0, y: 64, width: view.bounds.width, height: 258)
        pickerContentView.didMove(toParentViewController: self)
        
        let indicationView = _picker.indicationView
        addChildViewController(_picker.indicationView)
        view.addSubview(indicationView.view)
        indicationView.view.frame = CGRect(x: 0, y: 350, width: view.bounds.width, height: 60)
        indicationView.didMove(toParentViewController: self)
        
        view.addSubview(_button)
        _button.frame = CGRect(x: 0, y: view.bounds.height - 40, width: view.bounds.width, height: 40)
        _button.addTarget(self, action: #selector(ViewController._go), for: .touchUpInside)
    }
    
    @objc private func _go() {
        _picker.finishPickingImages { state in
            print(state)
        }
    }
    
    private lazy var _button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        return button
    }()
}

final class TestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}
