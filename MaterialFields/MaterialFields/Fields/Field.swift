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
     - DateField subclasses this but does not override the text or error function because it holds a Date value type and does not support error setting. DateField supports min and max dates meaning the user should never have the option to make an error.
*/
public class Field : UIView {
    /// The value in the text-based fields.
    public var text : String?
    
    //MARK:- COLORS
    
    /// Border color
    /// - Note: Defaults to UIColor.lightGray
    public var borderColor: UIColor = UIColor.lightGray
    
    /// Border color when field is active
    /// - Note: Defaults to the material field's baby blue
    public var borderHighlightColor: UIColor = UIColor.materialFieldsBlue
    
    /// Border color when there is an error in the field
    /// - Note: Defaults to UIColor.red
    public var borderErrorColor: UIColor = UIColor.red
    
    /// Normal text color
    /// - Note: Defaults to UIColor.black
    public var textColor: UIColor = UIColor.black
    
    /// Error text color
    /// - Note: Defaults to UIColor.red
    public var errorTextColor: UIColor = UIColor.red
    
    /// Color of placeholder label when down
    /// - Note: Defaults to UIColor.gray
    public var placeholderDownColor: UIColor = UIColor.gray
    
    /// Color of placeholder label when up
    /// - Note: Defaults to UIColor.black
    public var placeholderUpColor: UIColor = UIColor.black
    
    /// Color of cursor in field
    /// - Note: Defaults to UIColor.black.withAlphaComponent(0.5)
    public var cursorColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    
    /**
    Error setter for text-based fields.
    
     - Parameter withText: String for the error text label that will show up under the field
     - Note:
        - The error UI will dissapear automatically if the field becomes active again (EntryField, AreaField) or the values change (PickerField, DateField)
        - If you overrode the shakes property to false, the field does not shake during the transition animation the error state
    */
    public func setError(withText text: String?){
        
    }
}
