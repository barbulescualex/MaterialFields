//
//  AreaField.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-03-29.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit

/// EntryFieldDelegate protocol. Forwards all UITextView delegate methods.
@objc public protocol AreaFieldDelegate : AnyObject {
    
    ///Asks the delegate if editing should begin in the specified AreaField.
    /// - Parameter view: The AreaField that called the delegate method.
    @objc optional func areaFieldShouldBeginEditing(_ view: AreaField) -> Bool
    
    ///Tells the delegate that editing of the specified EntryField has begun.
    /// - Parameter view: The AreaField that called the delegate method.
    @objc optional func areaFieldDidBeginEditing(_ view: AreaField)
    
    ///Asks the delegate if editing should stop in the specified EntryField.
    /// - Parameter view: The AreaField that called the delegate method.
    @objc optional func areaFieldShouldEndEditing(_ view: AreaField) -> Bool
    
    ///Tells the delegate that editing of the specified EntryField has ended.
    /// - Parameter view: The AreaField that called the delegate method.
    @objc optional func areaFieldDidEndEditing(_ view: AreaField)
    
    /**
    Asks the delegate whether the specified text should be replaced in the EntryField.
    - Parameters:
        - view: The AreaField that called the delegate method.
        - range: The current selection range. If the length of the range is 0, range reflects the current insertion point. If the user presses the Delete key, the length of the range is 1 and an empty string object replaces that single character.
        - view: The text to insert.
    */
    @objc optional func areaField(_ view: AreaField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
}

/// Material version of the UITextView (multiline capable)
public class AreaField: Field, UIGestureRecognizerDelegate {
    //MARK:- TEXTVIEW VARS
    public override var placeholder : String? {
        didSet{
            if (isOptional && placeholder.isComplete()) {
                placeholderLabel.text = placeholder! + " (Optional)"
            }
            placeholderLabel.text = placeholder
        }
    }
    
    override public var text: String? {
        get{
            return textView.text
        }
        set{
            textView.text = newValue
            if newValue.isComplete() {
                animatePlaceholder(up: true)
            } else {
                animatePlaceholder(up: false)
            }
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
            textView.textColor = textColor
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
            textView.tintColor = cursorColor
        }
    }
    
    
    //OPTIONALS
    public override var isOptional : Bool {
        didSet{
            if let placeholder = placeholder {
                placeholderLabel.text = placeholder + " (Optional)"
            }
        }
    }
    
    public override var keyboardType: UIKeyboardType {
        didSet{
            textView.keyboardType = keyboardType
        }
    }
    
    public override var autocapitalizationType : UITextAutocapitalizationType {
        didSet{
            textView.autocapitalizationType = autocapitalizationType
        }
    }
    
    public override var autocorrectionType : UITextAutocorrectionType {
        didSet{
            textView.autocorrectionType = autocorrectionType
        }
    }
    
    public override var isSecureTextEntry: Bool {
        didSet{
            textView.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    //MARK:- VARS
    /// The reciever's delegate
    weak public var delegate : AreaFieldDelegate?
    
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
    
    /// The UITextView behind this field class
    public lazy var textView : UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.tintColor = UIColor.black.withAlphaComponent(0.5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .no
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0.5, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    /// Top 1px line of the fake shadow underneath the field
    private let borderTop : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
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
    
    /// The error label under the UITextField that appears on error being set
    public let errorLabel : UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
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
        translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        
        //stack and placeholder
        addSubview(stackView)
        stackView.addArrangedSubview(placeholderPlaceholder)
        stackView.addArrangedSubview(textView)
        
        //shadow
        let shadowStack = UIStackView()
        shadowStack.axis = .vertical
        shadowStack.addArrangedSubview(borderTop)
        shadowStack.addArrangedSubview(borderBottom)
        shadowStack.distribution = .fillEqually
        stackView.addArrangedSubview(shadowStack)
        stackView.setCustomSpacing(0, after: textView)
        
        //error label
        stackView.addArrangedSubview(errorLabel)
        errorLabel.isHidden = true
        
        //stack constraints
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        //placeholder constraints
        addSubview(placeholderLabel)
        placeholderYAnchorConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor, constant: -1)
        placeholderPlaceholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
        placeholderYAnchorConstraint.isActive = true
        
        //tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(startEditing(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    //MARK:- FUNCTIONS
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
    
    public override func removeErrorUI() {
        if !hasError { return }
        textView.textColor = textColor
        updateBorderColor(with: borderColor)
        placeholderLabel.textColor = placeholderUpColor
        hasError = false
        errorLabel.text = nil
        errorLabel.isHidden = false
    }
    
    /// Called from tap gesture recognizer on the field
    @objc func startEditing(_ sender: UIGestureRecognizer){
        textView.becomeFirstResponder()
    }
    
    override public func setError(withText text: String?) {
        hasError = true
        updateBorderColor(with: borderErrorColor)
        textView.textColor = borderErrorColor
        
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
    
    /**
     Notifies the field that it has been asked to relinquish its status as first responder in its window.
     This triggers the end callback from the field and closes the keyboard, removes the editing state.
     - Note: If it's in an error state it will keep its error UI.
     - Returns: true
     */
    override public func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
        isEditing(showHighlight: false)
        return true
    }
    
    /**
     Asks UIKit to make the field the first responder in its window.
     - Returns: true if became first responder, false otherwise
     */
    override public func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    /**
     Asks UIKit to make the EntryField is the first responder.
     Returns true if it becomes the first responder, false otherwise.
     */
    override public var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
    
    ///Returns a boolean indicating wether the EntryField can become the first responder
    public override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder
    }
    
    /// Removes observers.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- TEXTVIEW DELEGATE
extension AreaField : UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.areaFieldShouldBeginEditing?(self) ?? true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        isActive = true
        removeErrorUI()
        animatePlaceholder(up: true)
        isEditing(showHighlight: true)
        delegate?.areaFieldDidBeginEditing?(self)
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.areaFieldShouldEndEditing?(self) ?? true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text.isNotComplete()){
            animatePlaceholder(up: false)
        }
        delegate?.areaFieldDidEndEditing?(self)
        isEditing(showHighlight: false)
        isActive = false
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate?.areaField?(self, shouldChangeTextIn: range, replacementText: text) ?? true
    }
}

//MARK:- ANIMATIONS
extension AreaField {
    /**
     Animates the placeholder label upon a value being entered in the field
     - Parameter up: True will animate the placeholder up, false will animate the placeholder down
     */
    fileprivate func animatePlaceholder(up: Bool) {
        if(up){
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.placeholderLabel.textColor = self.placeholderUpColor
                self.placeholderYAnchorConstraint.isActive = false
                self.placeholderYAnchorConstraint = self.placeholderLabel.centerYAnchor.constraint(equalTo: self.placeholderPlaceholder.centerYAnchor)
                self.placeholderYAnchorConstraint.isActive = true
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 12)
                self.placeholderLabel.alpha = 0.7
                self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.placeholderUp = true
            })
        } else {//down
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.placeholderLabel.textColor = self.placeholderDownColor
                self.placeholderYAnchorConstraint.isActive = false
                self.placeholderYAnchorConstraint = self.placeholderLabel.centerYAnchor.constraint(equalTo: self.textView.centerYAnchor, constant: -1)
                self.placeholderYAnchorConstraint.isActive = true
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 18)
                self.placeholderLabel.alpha = 0.5
                self.layoutIfNeeded()
            }, completion: { (Bool) in
                self.placeholderUp = false
            })
        }
    }
}
