//
//  Colors.swift
//  DeviceDetector
//
//  Created by Bobby on 11/20/24.
//

import UIKit


let blueGradient: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.colors = [
        #colorLiteral(red: 0.14005059, green: 0.5947091579, blue: 0.9970223308, alpha: 1).cgColor,
        #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1.0, alpha: 1.0).cgColor
    ]
    layer.startPoint = CGPoint(x: 0, y: 0)
    layer.endPoint = CGPoint(x: 1, y: 1)
    return layer
}()
let primaryColor = #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) // Hex: #0A84FF
let secondaryColor = #colorLiteral(red: 0.368627451, green: 0.3607843137, blue: 0.9019607843, alpha: 1.0) // Hex: #5E5CE6
let accentColor = #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1.0) // Hex: #32D74B
let backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.968627451, alpha: 1.0) // Hex: #F5F5F7
let primaryTextColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1176470588, alpha: 1.0) // Hex: #1C1C1E
let secondaryTextColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1.0) // Hex: #8E8E93
let borderColor = #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7921568627, alpha: 1.0) // Hex: #C5C5CA
