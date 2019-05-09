//
//  Field.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-04-28.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

/**
Wrapper class for all fields. Makes data model validation and UI feedback a breeze.
- Attention:
      DateField subclasses this but does not override the text variable as it holds a Date value type
*/
public class Field : UIView {
    //MARK: Vars
    
    /// The value in the text-based fields.
    public var text : String?
    
    /// This is the placeholder, or "floating title" of the field
    public var placeholder : String?
    
    /// Optional setter to append and "(Optional)" tag to the field's placeholder
    /// - Note: Defualts to false
    public var isOptional : Bool = false
    
    //MARK: State Vars
    
    /// Read only flag to check if the field is currently active
    internal(set) public var isActive : Bool = false
    
    /// Read only flag to check if the field is currently in a error state
    internal(set) public var hasError : Bool = false
    
    /// Dictates if a field should shake if it has an error
    public var shakes : Bool = true
    
    //MARK: Keyboard Functionality
    
    /// Defines the type of keyboard that comes up when the field is active
    /// - Note: Defaults to .asciiCapable
    public var keyboardType: UIKeyboardType = .asciiCapable
    
    /// Defines the auto capitilazation type of the text entered
    /// - Note: Defaults to none
    public var autocapitalizationType : UITextAutocapitalizationType = .none
    
    /// Defines the autocorrection used on the field
    /// - Note: Defaults to none
    public var autocorrectionType : UITextAutocorrectionType = .default

    /// Defines if the field needs secure text entry (passwords)
    /// - Note: Defaults to false
    public var isSecureTextEntry : Bool = false
    
    /// A second tag element on the field
    public var tag2 : Int = 0
    
    
    //MARK: Colors
    
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
    
    //MARK: Error Functions
    /**
    Error setter for text-based fields.
    
     - Parameter withText: String for the error text label that will show up under the field
     - Note:
        - The error UI will dissapear automatically if the field becomes active again (EntryField, AreaField) or the values change (PickerField, DateField)
        - If you overrode the shakes property to false, the field does not shake during the transition animation the error state
    */
    public func setError(withText text: String?){
        
    }
    
    /**
     Clears error flag and UI from fields
     - Called automatically if the field becomes active again (EntryField, AreaField) or the values change (PickerField, DateField)
     */
    public func removeErrorUI(){
        
    }
}
