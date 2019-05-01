//
//  EntryField.swift
//  MaterialFields
//
//  Created by Alex Barbulescu on 2019-02-01.
//  Copyright © 2019 Alex Barbulescu. All rights reserved.
//

import UIKit


/// EntryFieldDelegate protocol. Forwards all the UITextField delegate methods.
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
    
    /// This is the optional placeholder, or "floating title" of the field
    public var placeholder : String? {
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
            textField.text = newValue
            if newValue.isComplete() {
                animatePlaceholder(up: true)
            } else {
                animatePlaceholder(up: false)
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
    
    /// Optional setter to append and "(Optional)" tag to the field's placeholder
    public var isOptional : Bool = false {
        didSet{
            if let placeholder = placeholder {
                placeholderLabel.text = placeholder + " (Optional)"
            }
        }
    }
    
    /// Defines if the field should shake upon setError() being called
    public var shakes : Bool = true
    
    /// Defines the type of keyboard that comes up when the field is active
    /// - Note: Defaults to .asciiCapable
    public var keyboardType: UIKeyboardType? {
        didSet{
            guard let type = keyboardType else {return}
            textField.keyboardType = type
        }
    }
    
    /// Defines the auto capitilazation type of the text entered
    /// - Note: Defaults to none
    public var autocapitalizationType : UITextAutocapitalizationType = .none {
        didSet{
            textField.autocapitalizationType = autocapitalizationType
        }
    }
    
    /// Defines the autocorrection used on the field
    /// - Note: Defaults to none
    public var autocorrectionType : UITextAutocorrectionType = .default {
        didSet{
            textField.autocorrectionType = autocorrectionType
        }
    }
    
    /// Defines if the field needs secure text entry (passwords)
    /// - Note: Defaults to false
    public var isSecureTextEntry : Bool = false {
        didSet{
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    /// Defines if the field is interactable
    /// - Note: Defaults to true
    public var isTextFieldInteractable : Bool = true {
        didSet{
            textField.isUserInteractionEnabled = isTextFieldInteractable
        }
    }
    
    //COLORS
    /// Border color
    /// - Note: Defaults to UIColor.lightGray
    public var borderColor: UIColor = UIColor.lightGray {
        didSet{
            if !isActive && !hasError {
                updateBorderColor(with: borderColor)
            }
        }
    }
    
    /// Border color when field is active
    /// - Note: Defaults to the material field's baby blue
    public var borderHighlightColor: UIColor = UIColor.materialFieldsBlue {
        didSet{
            if isActive {
                updateBorderColor(with: borderHighlightColor)
            }
        }
    }
    
    /// Border color when there is an error in the field
    /// - Note: Defaults to UIColor.red
    public var borderErrorColor: UIColor = UIColor.red {
        didSet{
            if hasError {
                updateBorderColor(with: borderErrorColor)
            }
        }
    }
    
    /// Normal text color
    /// - Note: Defaults to UIColor.black
    public var textColor: UIColor = UIColor.black {
        didSet{
            textField.textColor = textColor
        }
    }
    
    /// Normal text color
    /// - Note: Defaults to UIColor.black
    public var errorTextColor: UIColor = UIColor.red {
        didSet{
            errorLabel.textColor = errorTextColor
        }
    }
    
    public var placeholderDownColor: UIColor = UIColor.gray {
        didSet{
            if !placeholderUp {
                placeholderLabel.textColor = placeholderDownColor
            }
        }
    }
    
    public var placeholderUpColor: UIColor = UIColor.black {
        didSet{
            if placeholderUp {
                placeholderLabel.textColor = placeholderUpColor
            }
        }
    }
    
    public var cursorColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet{
            textField.tintColor = cursorColor
        }
    }
    
    public var monetaryColor: UIColor = UIColor.lightGray {
        didSet{
            dollarLabel.textColor = monetaryColor
        }
    }
    
    public var unitColor: UIColor = UIColor.lightGray {
        didSet{
            unitLabel.textColor = unitColor
        }
    }
    
    //MARK:- VARS
    weak public var delegate : EntryFieldDelegate?
    
    private var placeholderYAnchorConstraint: NSLayoutConstraint!
    private(set) var hasError = false
    private(set) var placeholderUp = false
    
    private var isActive = false
    
    //MARK:- VIEW COMPONENTS
    private let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let placeholderPlaceholder : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Subscribe to PewDiePie"
        label.textColor = UIColor.clear
        return label
    }()
    
    public let placeholderLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.alpha = 0.5
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    public lazy var textField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.tintColor = UIColor.black.withAlphaComponent(0.5)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let errorLabel : UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let unitLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dollarLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "$"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let borderTop : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    private let borderBottom : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    //MARK:- INIT
    public required init(){
        super.init(frame: .zero)
        setup()
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        setup()
    }
    
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
    
    @objc func startEditing(_ sender: UIGestureRecognizer){
        textField.becomeFirstResponder()
    }
    
    func removeErrorUI(){
        if(hasError){
            textField.textColor = textColor
            updateBorderColor(with: borderColor)
            placeholderLabel.textColor = placeholderUpColor
            hasError = false
            errorLabel.text = nil
            errorLabel.isHidden = true
        }
    }
    
    fileprivate func updateBorderColor(with color: UIColor){
        borderTop.backgroundColor = color
        borderBottom.backgroundColor = color.withAlphaComponent(0.5)
    }
    
    public func isEditing(showHighlight val: Bool){
        if hasError {return}
        if val {
            updateBorderColor(with: borderHighlightColor)
        } else {
            updateBorderColor(with: borderColor)
        }
    }
    
    override public func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override public func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override public var isFirstResponder: Bool {
        return textField.isFirstResponder
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


