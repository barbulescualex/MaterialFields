//
//  Extensions.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-04-10.
//  Copyright © 2019 alex. All rights reserved.
//

import UIKit

extension Optional where Wrapped == String {
    func isNotComplete() -> Bool! {
        return (self ?? "").isEmpty
    }
    
    func isComplete() -> Bool! {
        return !(self ?? "").isEmpty
    }
}

extension UIColor {
    static let babyBlue = UIColor(red: 45/255, green: 123/255, blue: 246/255, alpha: 1)
}
