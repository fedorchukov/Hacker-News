//
//  Date+String.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 10/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import Foundation

extension Date {
    
    func toShortString() -> String? {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: self, to: Date())
        if let days = components.day, days > 0 {
            return "\(days)d"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        }
        return nil
    }
}

