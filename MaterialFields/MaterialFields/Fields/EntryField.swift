//
//  EntryField.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit


/// EntryFieldDelegate protocol. Forwards UITextField delegate methods.
@objc public protocol EntryFieldDelegate : AnyObject {
    
    /// Asks the delegate if editing should begin in the specified EntryField.
    /// - Parameter view: The EntryField that called the delegate method
    @objc optional func entryFieldShouldBeginEditing(_ view: EntryField) -> Bool
    
    /// Tells the delegate that editing began in the specified EntryField.
    /// - Parameter view: The EntryField that called the delegate method
    @objc optional func entryFieldDidBeginEditing(_ view: EntryField)
    
    /// Asks the delegate if editing should stop in the specified EntryField.
    /// - Parameter view: The EntryField that called the delegate method
    @objc optional func entryFieldShouldEndEditing(_ view: EntryField) -> Bool
    
    /// Tells the delegate that editing stopped for the specified EntryField.
    /// - Parameter view: The EntryField that called the delegate method
    @objc optional func entryFieldDidEndEditing(_ view: EntryField)
    
    /// Asks the delegate if the EntryField should process the pressing of the return button.
    /// - Parameter view: The EntryField that called the delegate method
    @objc optional func entryFieldShouldReturn(_ view: EntryField) -> Bool
    
    /// Asks the delegate if the EntryField’s current contents should be removed.
    /// - Parameter view: The EntryField that called the delegate method
    @objc optional func entryFieldShouldClear(_ view: EntryField) -> Bool
}


/// Material version of the UITextField (single line, for multiline capability use the AreaField class)
public class EntryField: Field, UIGestureRecognizerDelegate {
    //MARK:- TEXTFIELD VARS
    
    public override var placeholder : String? {
        didSet{
            if (isOptional && placeholder.isComplete()) {
                placeholderLabel.text = placeholder! + " (Optional)"
            }
            placeholderLabel.text = placeholder
        }
    }
    
    /// The string value of the field
    override public var text: String? {
        get{
            return textField.text
        }
        set{
            //populate the textfield
            textField.text = newValue
            
            //animate the placeholder label
            if newValue.isComplete() {
                if !placeholderUp {
                    animatePlaceholder(up: true)
                }
            } else {
                if placeholderUp {
                    animatePlaceholder(up: false)
                }
            }
        }
    }
    
    //OPTIONALS
    /// Optional unit label that shows up on the right hand side of the field
    public var unit: String? {
        didSet{
            unitLabel.text = unit
        }
    }
    
    /// Optional setter to show a dollar sign on the left hand side of the field
    public var isMonetary : Bool = false {
        didSet{
            if placeholderUp {
                dollarLabel.isHidden = !isMonetary
            }
        }
    }
    
    public override var isOptional : Bool {
        didSet{
            if let placeholder = placeholder {
                placeholderLabel.text = placeholder + " (Optional)"
            }
        }
    }

    public override var keyboardType: UIKeyboardType {
        didSet{
            textField.keyboardType = keyboardType
        }
    }
    
    public override var autocapitalizationType : UITextAutocapitalizationType {
        didSet{
            textField.autocapitalizationType = autocapitalizationType
        }
    }
    
    public override var autocorrectionType : UITextAutocorrectionType {
        didSet{
            textField.autocorrectionType = autocorrectionType
        }
    }
    
    public override var isSecureTextEntry : Bool  {
        didSet{
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    //COLORS
    public override var borderColor: UIColor {
        didSet{
            if !isActive && !hasError {
                updateBorderColor(with: borderColor)
            }
        }
    }

    public override var borderHighlightColor: UIColor {
        didSet{
            if isActive {
                updateBorderColor(with: borderHighlightColor)
            }
        }
    }
    
    public override var borderErrorColor: UIColor {
        didSet{
            if hasError {
                updateBorderColor(with: borderErrorColor)
            }
        }
    }
    

    public override var textColor: UIColor {
        didSet{
            textField.textColor = textColor
        }
    }
    
    public override var errorTextColor: UIColor {
        didSet{
            errorLabel.textColor = errorTextColor
        }
    }
    
    public override var placeholderDownColor: UIColor {
        didSet{
            if !placeholderUp {
                placeholderLabel.textColor = placeholderDownColor
            }
        }
    }
    
    public override var placeholderUpColor: UIColor {
        didSet{
            if placeholderUp {
                placeholderLabel.textColor = placeholderUpColor
            }
        }
    }
    
    public override var cursorColor: UIColor {
        didSet{
            textField.tintColor = cursorColor
        }
    }
    
    /// Color of the dollar sign if the field is monetary
    /// - Note: Defualts to UIColor.lightGray
    public var monetaryColor: UIColor = UIColor.lightGray {
        didSet{
            dollarLabel.textColor = monetaryColor
        }
    }
    
    /// Color of the unit label if the field has a unit label
    /// - Note: Defualts to UIColor.lightGray
    public var unitColor: UIColor = UIColor.lightGray {
        didSet{
            unitLabel.textColor = unitColor
        }
    }
    
    //MARK:- VARS
    
    /// The reciever's delegate
    weak public var delegate : EntryFieldDelegate?
    
    /// Instance reference to the placeholder's Y constraint (for animation)
    private var placeholderYAnchorConstraint: NSLayoutConstraint!
    
    /// Flag to check if the placeholder is up to avoid unecessary animations
    private var placeholderUp = false
    
    
    //MARK:- VIEW COMPONENTS
    /// The stackview that encompasses the whole view
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// Invisable placeholder for the placeholder (the "title") above the field
    private let placeholderPlaceholder : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Subscribe to PewDiePie"
        label.textColor = UIColor.clear
        return label
    }()
    
    /// The placeholder label for the title
    public let placeholderLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.alpha = 0.5
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    /// The UITextField behind this field class
    public lazy var textField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.tintColor = UIColor.black.withAlphaComponent(0.5)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        return textField
    }()
    
    /// The error label under the UITextField that appears on error being set
    private let errorLabel : UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    /// The unit label that appears on the right hand side upon a unit String value being set
    private let unitLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// The dollar sign label that appears upon the field's isMonetary flag being set
    private let dollarLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "$"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    /// Top 1px line of the fake shadow underneath the field
    private let borderTop : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    /// Bottom 1px line of the fake shadow underneath the field
    private let borderBottom : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    //MARK:- INIT
    
    /**
    Required initializer if doing programtically. You can manually set the frame after initialization. Otherwise it relies on auto layout and it's intrinsic content size.
     - Warning: If you want to define a frame for it, make sure the height constant is a minimum of 41.
    */
    public required init(){
        super.init(frame: .zero)
        setup()
    }
    
    /// Interface builder initializer
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        setup()
    }
    
    ///Sets up the view
    fileprivate func setup(){
        textField.delegate = self
        
        //textfield and placeholder
        addSubview(stackView)
        addSubview(placeholderLabel)
        
        //text field stack
        let textFieldStack = UIStackView()
        textFieldStack.axis = .horizontal
        textFieldStack.distribution = .fill
        textFieldStack.addArrangedSubview(dollarLabel)
        textFieldStack.addArrangedSubview(textField)
        
        stackView.addArrangedSubview(placeholderPlaceholder)
        stackView.addArrangedSubview(textFieldStack)
        
        //unit label
        textFieldStack.addSubview(unitLabel)
        unitLabel.centerYAnchor.constraint(equalTo: textFieldStack.centerYAnchor, constant: 0).isActive = true
        unitLabel.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor, constant: -5).isActive = true
        
        dollarLabel.isHidden = true
        
        //shadow
        let shadowStack = UIStackView()
        shadowStack.axis = .vertical
        shadowStack.addArrangedSubview(borderTop)
        shadowStack.addArrangedSubview(borderBottom)
        shadowStack.distribution = .fillEqually
        stackView.addArrangedSubview(shadowStack)
        stackView.setCustomSpacing(0, after: textFieldStack)
        
        //error label
        stackView.addArrangedSubview(errorLabel)
        errorLabel.isHidden = true
        
        //stack constraints
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        //placeholder constraints
        placeholderYAnchorConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: -1)
        placeholderYAnchorConstraint.isActive = true
        
        
        //Gesture Recognizer to make the whole area interactable
        let tap = UITapGestureRecognizer(target: self, action: #selector(startEditing(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    //MARK:- FUNCTIONS
    override public func setError(withText text: String?) {
        hasError = true
        updateBorderColor(with: borderErrorColor)
        textField.textColor = borderErrorColor
        
        if(!placeholderUp){
            placeholderLabel.textColor = errorTextColor
        }
        
        if shakes {
            let shake = CABasicAnimation(keyPath: "position")
            shake.duration = 0.05
            shake.repeatCount = 2
            shake.autoreverses = true
            shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
            shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
            self.layer.add(shake, forKey: "position")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.errorLabel.text = text
                self.errorLabel.isHidden = false
            }
        } else {
            self.errorLabel.text = text
            self.errorLabel.isHidden = false
        }
    }
    
    /// Called from tap gesture recognizer on the field
    @objc func startEditing(_ sender: UIGestureRecognizer){
        textField.becomeFirstResponder()
    }
    
    public override func removeErrorUI() {
        if !hasError {return}
        textField.textColor = textColor
        updateBorderColor(with: borderColor)
        placeholderLabel.textColor = placeholderUpColor
        hasError = false
        errorLabel.text = nil
        errorLabel.isHidden = true
    }
    
    /**
    Updates the border color by creating a gradient for the 1px height lines that make up the border/shadow effect
     - Parameter color: Color to set the border to
    */
    fileprivate func updateBorderColor(with color: UIColor){
        borderTop.backgroundColor = color
        borderBottom.backgroundColor = color.withAlphaComponent(0.5)
    }
    
    /**
    Sets the editing state on and off by either showing the highlight color or regular color (does not change the state if the field currently has an error
     - Parameter showHighlight: setter for wether it should show highlight colors
     */
    internal func isEditing(showHighlight val: Bool){
        if hasError {return}
        if val {
            updateBorderColor(with: borderHighlightColor)
        } else {
            updateBorderColor(with: borderColor)
        }
    }
    
    /**
     Notifies the field that it has been asked to relinquish its status as first responder in its window.
     This triggers the end callback from the field, closes the keyboard, and removes the editing state.
     - Note: If it's in an error state it will keep its error UI.
     - Returns: true
     */
    override public func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        isEditing(showHighlight: false)
        return true
    }
    
    /**
     Asks UIKit to make the field the first responder in its window.
     - Returns: true if became first responder, false otherwise
     */
    override public func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    /**
     Asks UIKit to make the EntryField is the first responder.
     Returns true if it becomes the first responder, false otherwise.
     */
    override public var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
    
    ///Returns a boolean indicating wether the EntryField can become the first responder
    public override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
}

//MARK:- TEXTFIELD DELEGATE
extension EntryField : UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // print("text field should begin editing")
        let answer = delegate?.entryFieldShouldBeginEditing?(self) ?? true
        // print("text field should begin editing answer: ", answer)
        return answer
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // print("text field did begin editing")
        isActive = true
        removeErrorUI()
        animatePlaceholder(up: true)
        delegate?.entryFieldDidBeginEditing?(self)
        isEditing(showHighlight: true)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //print("text field should end editing")
        let answer = delegate?.entryFieldShouldEndEditing?(self) ?? true
        //print("text field should end editing answer: ", answer)
        return answer
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        //print("text field did end editing")
        if(textField.text.isNotComplete()){
            animatePlaceholder(up: false)
        }
        delegate?.entryFieldDidEndEditing?(self)
        isEditing(showHighlight: false)
        isActive = false
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print("text field should return")
        let answer = delegate?.entryFieldShouldReturn?(self) ?? true
        //print("text field should return answer: ", answer)
        return answer
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //print("text field should clear")
        let answer = delegate?.entryFieldShouldClear?(self) ?? true
        //print("text field should clear answer: ", answer)
        return answer
    }
}

//MARK:- ANIMATIONS
extension EntryField {
    /**
     Animates the placeholder label upon a value being entered in the field
     - Parameter up: True will animate the placeholder up, false will animate the placeholder down
     */
    fileprivate func animatePlaceholder(up: Bool) {
        if(up){
            dollarLabel.isHidden = !isMonetary
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //Positioning
                self.placeholderYAnchorConstraint.isActive = false
                self.placeholderYAnchorConstraint = self.placeholderLabel.centerYAnchor.constraint(equalTo: self.placeholderPlaceholder.centerYAnchor)
                self.placeholderYAnchorConstraint.isActive = true
                
                //Look
                self.placeholderLabel.textColor = self.placeholderUpColor
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 12)
                self.placeholderLabel.alpha = 0.7
                self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.placeholderUp = true
            })
        } else {//down
            dollarLabel.isHidden = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                //Positioning
                self.placeholderYAnchorConstraint.isActive = false
                self.placeholderYAnchorConstraint = self.placeholderLabel.centerYAnchor.constraint(equalTo: self.textField.centerYAnchor, constant: -1)
                self.placeholderYAnchorConstraint.isActive = true
                
                //Look
                self.placeholderLabel.textColor = self.placeholderDownColor
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 18)
                self.placeholderLabel.alpha = 0.5
                self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.placeholderUp = false
            })
        }
    }
}


