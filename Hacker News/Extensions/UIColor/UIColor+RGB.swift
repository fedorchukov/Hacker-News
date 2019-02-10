//
//  UIColor+RGB.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 08/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let carrot = UIColor(hex: 0xF66200)
    static let aluminum = UIColor(hex: 0xE8E7EC)
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, alpha: alpha)
    }
}

