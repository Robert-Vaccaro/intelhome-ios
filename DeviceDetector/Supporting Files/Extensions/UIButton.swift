//
//  UIButton.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//

import UIKit

extension UIButton {
    func applyCustomStyle(title: String) {
        self.setTitle(title, for: .normal)
        self.backgroundColor = .black
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 25
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4.0
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}
