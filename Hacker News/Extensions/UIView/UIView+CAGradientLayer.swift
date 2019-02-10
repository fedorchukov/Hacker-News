//
//  UIView+CAGradientLayer.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 08/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import UIKit

extension UIView {
    
    func startShimmer() {
        let transparent = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75).cgColor
        let opaque = UIColor.black.cgColor
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [opaque, transparent, opaque]
        gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: self.bounds.size.width * 3, height: self.bounds.size.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0.1, 1.0]
        self.layer.mask = gradient
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        
        animation.duration = 0.8
        animation.repeatCount = HUGE
        gradient.add(animation, forKey: "shimmer")
    }
    
    func stopShimmer() {
        self.layer.mask = nil
    }
}

