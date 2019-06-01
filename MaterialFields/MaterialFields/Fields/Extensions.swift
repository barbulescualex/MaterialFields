//
//  Extensions.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-04-10.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

public extension Optional where Wrapped == String {
    /**
    Checks if string is not complete meaning nil or ""
    - Note:
         - Called on optional string
    */
    func isNotComplete() -> Bool! {
        return (self ?? "").isEmpty
    }
    
    /**
     Checks if string is complete meaning not nil or ""
     - Note:
        - Called on optional string
     */
    func isComplete() -> Bool! {
        return !(self ?? "").isEmpty
    }
}

extension UIColor {
    /// Baby blue color used as the defualt color for all Field types
    static let materialFieldsBlue = UIColor(red: 45/255, green: 123/255, blue: 246/255, alpha: 1)
}
