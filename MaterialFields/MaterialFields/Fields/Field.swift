//
//  Field.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-04-28.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

/**
Wrapper class for all fields. Offers wrapper functionality for all text-based fields.
- Attention:
     - DateField subclasses this but does not override its variables or functions because it holds a Date value type and does not support error setting. DateField supports min and max dates meaning the user should never have the option to make an error.
*/
public class Field : UIView {
    /// The value in the text-based fields.
    public var text : String?
    
    /// Error setter for text-based fields.
    public func setError(withText text: String?){
        
    }
}
